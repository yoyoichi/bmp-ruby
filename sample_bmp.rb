# coding: utf-8
#
#  sample_bmp.rb
#
# Copyright (c) 2014 Yoichi Yokogawa
#
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

require './bmp.rb'

begin
  image1 = BitMap.new(32, 32)
  image1.clear(224, 224, 224)
  image1.write('test_image1.bmp')

  image2 = BitMap.new(64, 64)
  64.times do |y|
    64.times do |x|
      d = Math.sqrt((x - 31.5) ** 2 + (y - 31.5) ** 2)
      r = (5.0 * (50.0 - d)).round
      g = (5.0 * (50.0 - d)).round
      b = 250
      image2.pset(x, y, r, g, b)
    end
  end

  # 本当はimage1をそのまま使ってよいが、サンプルとして
  image3 = BitMap.read('test_image1.bmp')

  image2.paste(image3, 0, 32)
  image2.set_dpi(150)
  image2.write('test_image2.bmp')
end
