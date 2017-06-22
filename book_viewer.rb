require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

helpers do
  def paragraphs(txt)
    content_with_anchors = ""
    txt.split("\n\n").each_with_index do |paragraph, index|
      content_with_anchors << "<p id='link#{index}'>#{paragraph}</p>"
    end
    content_with_anchors
  end

  def bold_matched_text(txt, keyword)
    new_txt = txt.gsub(keyword, "<strong>#{keyword}</strong>")
    new_txt
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/search" do
  if params[:query]
    keyword = params[:query]
    @matched_chapters = {}
    1.upto(@contents.length) do |chapter_number|
      chapter_content = File.read("data/chp" + chapter_number.to_s + ".txt")
      if chapter_content.match(keyword)
        chapter_name = @contents[chapter_number - 1]
        paragraphs = chapter_content.split("\n\n")
        matched_paragraphs = []
        paragraphs.each_with_index do |paragraph, index|
          if paragraph.match(keyword)
            matched_paragraphs << [paragraph, index]
          end
        end
        @matched_chapters[chapter_number] = [chapter_name, matched_paragraphs]
      end
      
    end
  end
  erb :search
end

get "/" do
  @title = "This is a title"
  erb :index
end

get "/chapters/:chapter_number" do
  chapter_number = params[:chapter_number]
  @chapter = File.read("data/chp" + chapter_number + ".txt")
  chapter_name = @contents[chapter_number.to_i - 1]
  @title = "Chapter #{chapter_number} #{chapter_name}"
  erb :chapter
end

not_found do
  redirect "/"
end