#
# Be sure to run `pod lib lint CoreDataContextManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CoreDataContextManager'
  s.version          = '0.0.9'
  s.summary          = 'CoreData helpers for database auto-migration and multi threading.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
CoreDataContextManager is CoreData helper library.
It provides the following features:

- Auto-migration with xcdatamodel file versions
- Multi threading with context management
- General implementation of NSFetchedResultsControllerDelegate

See GitHub for usage and more details.
                       DESC

  s.homepage         = 'https://github.com/wagyu298/CoreDataContextManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Unlicense', :file => 'LICENSE' }
  s.author           = { 'wagyu298' => 'wagyu298@gmail.com' }
  s.source           = { :git => 'https://github.com/wagyu298/CoreDataContextManager.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/wagyu298'

  s.ios.deployment_target = '7.1'

  s.source_files = 'CoreDataContextManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CoreDataContextManager' => ['CoreDataContextManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
