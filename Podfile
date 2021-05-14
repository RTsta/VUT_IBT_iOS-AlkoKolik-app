# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AlkoKolik' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AlkoKolik

  pod 'Charts'

end

target 'AlkoKolik WatchKit App' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AlkoKolik WatchKit App

end

target 'AlkoKolik WatchKit Extension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AlkoKolik WatchKit Extension

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
