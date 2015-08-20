Pod::Spec.new do |s|
  s.name         		= "ReactiveCryptor"
  s.version      		= "1.0.1"
  s.summary      		= "An adaptation of RNCryptor to ReactiveCocoa."
  s.description  		= <<-DESC
					An adaptation of RNCryptor to ReactiveCocoa.

					This is just some code to join Rob Napier's excellent RNCryptor to ReactiveCocoa 
					while hopefully preserving all of the power and flexibility of both.

					The big innovation that I'm working on is using NSStream objects to restrain 
					memory usage.
		                   DESC

  s.homepage     		= "https://github.com/ndouglas/ReactiveCryptor"
  s.license      		= { :type => "Public Domain", :file => "LICENSE" }
  s.author             		= { "Nathan Douglas" => "ndouglas@devontechnologies.com" }
  s.ios.deployment_target 	= "7.0"
  s.osx.deployment_target 	= "10.8"
  s.source       		= { :git => "https://github.com/ndouglas/ReactiveCryptor.git", :tag => "1.0.1" }
  s.source_files  		= "*.{h,m}"
  s.exclude_files 		= "*.Tests.m"
  s.dependency 			"RNCryptor"
  s.dependency			"ReactiveCocoa"
end
