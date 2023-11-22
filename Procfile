web: dokku run coesfau bundle exec puma -C config/puma.rb
worker: dokku run coesfau rake jobs:work
release: dokku run coesfau rake db:migrate
