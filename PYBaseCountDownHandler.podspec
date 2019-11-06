

Pod::Spec.new do |s|
  s.name             = 'PYBaseCountDownHandler'
  s.version          = '0.1.3'
  s.summary          = '倒计时工具： 支持优效率的列表倒计时 和 对时间的处理、比较'

  s.description      = <<-DESC
倒计时工具： 支持优效率的列表倒计时 和 对时间的处理、比较
                       DESC

  s.homepage         = 'https://github.com/LiPengYue/PYBaseCountDownHandler'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LiPengYue' => 'pengyue.li@yi23.net' }
  s.source           = { :git => 'https://github.com/LiPengYue/PYBaseCountDownHandler.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'PYBaseCountDownHandler/Classes/**/*'
  
end
