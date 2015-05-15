
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'google-search'
require 'open-uri'
require 'opencv'
include OpenCV

if ARGV.length < 2
  puts "Usage: ruby #{__FILE__} infile outfile"
  exit
end
infile, outfile = ARGV

tmpdir = './download'
data = '../examples/data/haarcascade_frontalface_alt.xml'
detector = CvHaarClassifierCascade::load(data)
outfile = File.open(outfile, 'w')

File.open(infile).each do |line|
  line = line.strip
  Google::Search::Image.new(:query => line + ' site:ustc.edu.cn').each do |image|
    print "GET ", line, "\t", image.uri, "\t"
    extname = File.extname(image.uri).downcase
    if ['.gif'].include? extname
      print "extension " + extname + " not recognized\n"
      next
    end
    savename = tmpdir + '/' + line + extname
    begin
      File.open(savename, 'wb') do |file|
        file << open(image.uri).read 
      end
    rescue
      print "Download failed\n"
      next
    end
    begin
      cv_image = CvMat.load(savename)
      num_people = detector.detect_objects(cv_image).length
      if num_people == 1
        outfile.write line + "\t" + image.uri + "\n"
        outfile.flush
        print "OK\n"
        break
      else
        print "recognized " + num_people + " people\n"
        next
      end
    rescue
      print "OpenCV read failed\n"
      next
    end
  end
end
