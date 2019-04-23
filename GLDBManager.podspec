Pod::Spec.new do |s|
  s.name         = 'GLDBManager'
  s.version      = '1.0.2'
  s.license      = { :type => 'MIT'}
  s.homepage     = 'https://github.com/GrayLand119/GLDBManager'
  s.authors      = {'GrayLand119' => '441726442@qq.com'}
  s.summary      = '基于FMDB的轻量级数据库插件, 面向对象地进行数据库操作'
  s.platform     =  :ios, '8.0'
  s.source       =  { :git => 'https://github.com/GrayLand119/GLDBManager.git', :tag => s.version.to_s }
  s.source_files = 'GLDBManagerDemo/GLDBManager/**/*.{h,m}'
  s.requires_arc = true
  s.dependency 'FMDB'
  s.dependency 'YYModel'
end
