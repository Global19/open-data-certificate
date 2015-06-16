require File.join(Rails.root, 'lib/extra/certificate_factory.rb')

task :certificate do
  if ENV['URL'] && ENV['USER_ID']
    cert = CertificateFactory::Certificate.new(ENV['URL'], ENV['USER_ID'])
    gen = cert.generate
  else
    puts "You must specifiy the Certificate URL and User ID"
  end
end

task :certificates do
  url = ENV['URL']
  user_id = ENV['USER_ID']
  CertificateFactory::Factory.new(feed: url, user_id: user_id, limit: nil, campaign: nil, logger: nil).build
end
