bmp-ruby
========


Introduction
------------

**bmp-ruby** is a lightweight library for reading and writing Windows BMP files.
**bmp-ruby** is written in Ruby.

Supported reading/writing formats:

* RGB 8,8,8 (no compression)

Bitmap files with image data in bottom-to-top order (common) is supported.


RubyでBMP画像(Windowsビットマップ)を扱うためのライブラリです。

現状では、無圧縮の24bitカラー(1677万色)にのみ対応しています。

このライブラリを使ってできること

* 新しいビットマップ画像を生成する
* 既存のBMPファイルを読み込む
* ビットマップ画像全体を一色で塗りつぶし
* ビットマップ画像のピクセル単位の色の読み込み/書き換え
* ビットマップ画像の切り抜き(クリッピング)
* ひとつのビットマップ画像の上に別のビットマップ画像を貼り付ける
* BMPファイルとして書き出す


## 新しいビットマップ画像を生成する

```ruby
require './bmp.rb'

new_image = BitMap.new(width, height, dpi)
```

※ dpiのパラメータは省略できます(その場合、96dpiとなる)。


## 既存のBMPファイルを読み込む

```ruby
loaded_image = BitMap.read(filename)
```


## ビットマップ画像全体を一色で塗りつぶし

```ruby
image.clear(red, green, blue)
```

※ red, green, blue各色は 0～255 の整数


## ビットマップ画像のピクセル単位の色の読み込み

```ruby
color = image.pget(x, y)
red   = color[0]
green = color[1]
blue  = color[2]
```

※ x, y は整数であること  
※ 座標系は画像の左上を原点として、右方向、下方向が正になります。


## ビットマップ画像のピクセル単位の色の書き換え

```ruby
image.pset(x, y, red, green, blue)
```

※ x, y は整数であること  
※ red, green, blue各色は 0～255 の整数

## ビットマップ画像の切り抜き(クリッピング)

```ruby
clipped_image = original_image.clip(x1, y1, x2, y2)
```

※ x1 <= x2, y1 <= y2 にしてください


## ひとつのビットマップ画像の上に別のビットマップ画像を貼り付ける

```ruby
base_image.paste(image, x0, y0)
```

※ x0, y0 は、image の左上を base_image のどこに置くかの指定です。  
※ x0, y0 は整数であること


## BMPファイルとして書き出す

```ruby
image.write(filename)
```
