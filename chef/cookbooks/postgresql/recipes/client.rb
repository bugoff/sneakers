include_recipe "postgresql::repository"

%w[postgresql-client libpq-dev].each do |pg_package|
  package pg_package
end
