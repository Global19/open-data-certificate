require 'test_helper'

class CertificateTest < ActiveSupport::TestCase

  def setup
    Certificate.destroy_all

    @certificate1 = FactoryGirl.create(:response_set_with_dataset).certificate
    @certificate2 = FactoryGirl.create(:response_set_with_dataset).certificate
    @certificate3 = FactoryGirl.create(:response_set_with_dataset).certificate

    @certificate1.update_attributes(name: 'Banana certificate', curator: 'John Smith')
    @certificate2.update_attributes(name: 'Monkey certificate', curator: 'John Wards')
    @certificate3.update_attributes(name: 'Monkey banana certificate', curator: 'Frank Smith')

    @certificate1.response_set.survey.update_attributes(full_title: 'United Kingdom')
    @certificate2.response_set.survey.update_attributes(full_title: 'United States')
    @certificate3.response_set.survey.update_attributes(full_title: 'Wales')
  end

  test 'search title matches single term' do
    assert_equal [@certificate1, @certificate3], Certificate.search_title('banana')
  end

  test 'search title matches multiple terms' do
    assert_equal [@certificate3], Certificate.search_title('certificate Monkey banana')
  end

  test 'search publisher matches single term' do
    assert_equal [@certificate1, @certificate2], Certificate.search_publisher('JOHN')
  end

  test 'search publisher matches multiple terms' do
    assert_equal [@certificate3], Certificate.search_publisher('Frank Smith')
  end

  test 'search country matches single term' do
    assert_equal [@certificate1, @certificate2], Certificate.search_country('United')
  end

  test 'search country matches multiple terms' do
    assert_equal [@certificate1], Certificate.search_country('United Kingdom')
  end

  test 'verified by user' do
    cv = FactoryGirl.create(:verification)
    user2 = FactoryGirl.create(:user)

    assert cv.certificate.verified_by_user? cv.user
    refute cv.certificate.verified_by_user? user2
  end

  test 'certification_type' do
    certificate = FactoryGirl.create(:response_set_with_dataset).certificate

    assert_equal :self, certificate.certification_type,
                        'defaults to self certified'

    2.times do
      FactoryGirl.create :verification, certificate: certificate
    end

    assert_equal :community, certificate.certification_type,
                             'community certifified when verified by 2 users'

  end

  test 'published_certificates' do
    @certificate1.update_attributes(published: true)
    @certificate2.update_attributes(published: true)
    @certificate3.update_attributes(published: true)

    assert_equal 3, Certificate.published.count
  end

  test 'progress_by_level' do
    certificate = FactoryGirl.create(:response_set_with_dataset).certificate

    certificate.stubs(:progress).returns({
        mandatory: 3,
        mandatory_completed: 11,
        outstanding: [
          "basic_1",
          "basic_2",
          "pilot_6",
          "pilot_7",
          "pilot_8",
          "standard_11",
          "standard_12",
          "standard_13",
          "exemplar_16",
          "exemplar_18",
          "exemplar_19"
        ],
        entered: [
          "basic_3",
          "basic_4",
          "basic_5",
          "pilot_9",
          "pilot_10",
          "standard_14",
          "standard_15"
        ]
      })

    progress = certificate.progress_by_level

    assert_equal progress[:basic], 73.7
    assert_equal progress[:pilot], 66.7
    assert_equal progress[:standard], 62.1
    assert_equal progress[:exemplar], 56.3
  end

  test "status returns the expected status" do
    @certificate1.update_attributes(published: true)
    assert_equal @certificate1.status, "published"

    @certificate1.update_attributes(published: false)
    assert_equal @certificate1.status, "draft"
  end

  test 'days_to_expiry returns correct number of days' do
    @certificate1.expires_at = DateTime.now + 14
    @certificate1.save

    assert_equal 14, @certificate1.days_to_expiry
  end
end
