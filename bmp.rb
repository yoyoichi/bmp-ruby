# coding: utf-8
#
#  bmp.rb  -- a toolkit for bitmap(BMP) image
#
# Copyright (c) 2014 Yoichi Yokogawa
#
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php
#
# ※ BMPファイルのファイルフォーマットについては、
#    http://www.kk.iij4u.or.jp/~kondo/bmp/ を参考にしました

class BitMap
  def initialize(width, height, dpi = 96)
    @width = width
    @height = height
    @line_size = width * 3 + (4 - (width * 3) % 4) % 4
    @buf_size = @line_size * height
    @buf = ("\000" * @buf_size).encode('BINARY')
    @bit_count = 24
    @compression = 0  # 圧縮無し
    @size_image = 0
    @x_pix_per_meter = (39.375 * dpi).round
    @y_pix_per_meter = (39.375 * dpi).round
    @clr_used = 0
    @cir_important = 0
  end

  def clear(r = 255, g = 255, b = 255)
    line = b.chr * @line_size
    @width.times do |x|
      line[x * 3 + 1] = g.chr
      line[x * 3 + 2] = r.chr
    end

    @buf = line * @height
  end

  attr_writer :buf
  attr_reader :width, :height

  # BMPファイルを出力する
  def write(filename)
    file_size = 14 + 40 + @buf_size
    data_offset = 14 + 40

    open(filename, "wb") do |f|
      f.print 'BM'
      f.print [file_size, 0, data_offset].pack("l*")
      f.print [40, @width, @height].pack("l*")
      f.print [1, @bit_count].pack("S*")
      f.print [@compression, @size_image,
               @x_pix_per_meter, @y_pix_per_meter,
               @clr_used, @cir_important].pack("l*")
      f.print @buf
    end
  end


  # BMPファイルを読み込む
  def BitMap.read(filename)
    buf = nil
    open(filename, "rb") do |f|
      buf = f.read
    end

    if buf[0] != ?B or buf[1] != ?M
      raise '[Error] read: Invalid Header'
    end
    real_buf_size = buf.size
    buf_size = (buf[2, 4].unpack("l*"))[0]
    if buf_size > real_buf_size
      raise '[Error] read: Invalid Buffer Size'
    end
    data_offset = (buf[10, 4].unpack("l*"))[0]
    if data_offset != 54
      raise '[Error] read: Invalid Data Offset'
    end

    width = (buf[18, 4].unpack("l*"))[0]
    height = (buf[22, 4].unpack("l*"))[0]

    bit_count = (buf[28, 2].unpack("s*"))[0]
    if bit_count != 24
      raise '[Error] read: Unsupported Color Depth'
    end

    compression = (buf[30, 4].unpack("l*"))[0]
    if compression != 0
      raise '[Error] read: Compression Not Supported'
    end

    pix_per_meter = (buf[38, 4].unpack("l*"))[0]
    dpi = pix_per_meter / 39.375

    image_buf = buf[54, buf_size]

    image = BitMap.new(width, height, dpi)
    image.buf = image_buf

    return image
  end


  # (x1, y1) - (x2, y2)の部分画像を取り出す
  def clip(x1, y1, x2, y2)
    return  if x1 > x2
    return  if y1 > y2
    return  if x2 < 0
    return  if y2 < 0
    return  if x1 >= @width
    return  if y1 >= @height
    x1 = 0  if x1 < 0
    y1 = 0  if y1 < 0
    x2 = @width - 1   if x2 >= @width
    y2 = @height - 1  if y2 >= @height

    clip_width  = x2 - x1 + 1
    clip_height = y2 - y1 + 1

    clip_image = BitMap.new(clip_width, clip_height, self.get_dpi)

    for y in 0 .. (clip_height - 1)
      for x in 0 .. (clip_width - 1)
        color = self.pget(x1 + x, y1 + y)
        clip_image.pset(x, y, color[0], color[1], color[2])
      end
    end

    return clip_image
  end


  # 1ピクセル描画
  # x, y, r, g, b は整数であることを期待している
  def pset(x, y, r, g, b)
    return  if x < 0 or @width <= x
    return  if y < 0 or @height <= y
    r = 0  if r < 0
    g = 0  if g < 0
    b = 0  if b < 0
    r = 255  if r > 255
    g = 255  if g > 255
    b = 255  if b > 255

    @buf[(@height - 1 - y) * @line_size + x * 3    ] = b.chr
    @buf[(@height - 1 - y) * @line_size + x * 3 + 1] = g.chr
    @buf[(@height - 1 - y) * @line_size + x * 3 + 2] = r.chr
  end

  # 1ピクセル読み取り
  # x, yは整数であることを期待している
  # 戻り値は[r, g, b]な配列
  def pget(x, y)
    x = 0  if x < 0
    x = @width - 1  if x >= @width
    y = 0  if y < 0
    y = @height - 1  if y >= @height

    addr = (@height - 1 - y) * @line_size + x * 3
    b = @buf[addr    ].ord
    g = @buf[addr + 1].ord
    r = @buf[addr + 2].ord

    return [r, g, b]
  end

  def get_dpi()
    return (@x_pix_per_meter / 39.375).round
  end

  def set_dpi(dpi)
    @x_pix_per_meter = (39.375 * dpi).round
    @y_pix_per_meter = @x_pix_per_meter
  end

  # BMP画像の貼り付け
  # x0, y0 は、貼り付ける始点(左上)の座標
  def paste(image, x0 = 0, y0 = 0)
    return  if image == nil
    image.height.times do |from_y|
      y = y0 + from_y
      next  if y < 0 or @height <= y

      image.width.times do |from_x|
        x = x0 + from_x
        next  if x < 0 or @width <= x
        color = image.pget(from_x, from_y)
        self.pset(x, y, color[0], color[1], color[2])
      end
    end

  end
end
