web: bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work RAILS_ENV=production 
release: bundle exec rake db:migrate
