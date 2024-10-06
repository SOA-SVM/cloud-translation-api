#  frozen_string_literal: true

require 'http'
require 'yaml'

def load_config
  YAML.safe_load(File.read('config/secrets.yml'))
end

def trans_api_path
  'https://translation.googleapis.com/language/translate/v2'
end

def send_translation_request(api_key, source_texts, target_language)
  HTTP.post(
    trans_api_path,
    params: {
      q: source_texts,
      target: target_language,
      key: api_key
    }
  )
end

def parse_response(response)
  JSON.parse(response.body.to_s)
end

def extract_translations(parsed_response)
  parsed_response['data']['translations'].map do |translation|
    {
      translated_text: translation['translatedText'],
      detected_source_language: translation['detectedSourceLanguage']
    }
  end
end

def save_to_yaml(file_path, texts, translations)
  File.open(file_path, 'w') do |file|
    file.write({
      texts:,
      translations:
    }.to_yaml)
  end
end

config = load_config
api_key = config['Google_Translation_Token']

texts = [
  'Hello, world!', # test_en
  '天気がいいから、散歩しましょう。', # test_ja
  "C'est la vie", # test_fr
  'Eso si que es' # test_es
]
target_language = 'zh-TW'

response = send_translation_request(api_key, texts, target_language)

parsed_response = parse_response(response)
translations = extract_translations(parsed_response)

translations.each_with_index do |translation, index|
  original_text = texts[index]
  translated_text = translation[:translated_text]
  detected_language = translation[:detected_source_language]

  puts "Original Text #{index + 1}: #{original_text}"
  puts "Translated Text: #{translated_text}"
  puts "Detected Source Language: #{detected_language}"

  puts '---------------------------'
end

save_to_yaml('spec/fixtures/translation-results.yml', texts, translations)

puts 'Translation result saved to spec/fixtures/translation-results.yml'
