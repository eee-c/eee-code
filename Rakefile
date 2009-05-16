task :default => [:test]

task :test => [:app_specs, :helper_specs, :view_specs]

task :app_specs do
  system("spec", "./spec/eee_spec.rb")
end

task :helper_specs do
  system("spec", "./spec/eee_helpers_spec.rb")
end

task :view_specs do
  system("spec ./spec/views/*.haml_spec.rb")
end
