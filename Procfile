web: bundle exec puma -C config/puma.rb
worker: RAILS_ENV=production bundle exec rake jobs:work
release: bundle exec rake db:migrate
