require 'kor/input/yaml'

module KorInputYamlTest
  def test_initialize(t)
    _, err = go { Kor::Input::Yaml.new }
    unless ArgumentError === err
      t.error("expect raise an ArgumentError got #{err.class}:#{err}")
    end

    _, err = go { Kor::Input::Yaml.new(nil) }
    if err != nil
      t.error("expect not raise an error got #{err.class}:#{err}")
    end
  end

  def ready
    io = StringIO.new(<<-YAML)
---
foo: 100
bar: 200
---
bar: 500
baz: 600
YAML
    Kor::Input::Yaml.new(io)
  end

  def test_head(t)
    yaml = ready
    head = yaml.head
    expect = %w(foo bar baz)
    if head != expect
      t.error("expect #{expect} got #{head}")
    end
  end

  def test_head_with_prekeys(t)
    yaml = ready
    opt = OptionParser.new
    yaml.parse(opt)
    opt.parse ["--key=bar,foo"]

    head = yaml.head
    expect = ["bar", "foo"]
    if head != expect
      t.error("expect #{expect} got #{head}")
    end
  end

  def test_gets(t)
    yaml = ready
    yaml.head

    expects = [
      [100, 200, nil],
      [nil, 500, 600],
      nil, nil, nil, nil, nil
    ].each do |expect|
      actual = yaml.gets
      if actual != expect
        t.error("expect #{expect} got #{actual}")
      end
    end
  end

  def test_gets_with_none_guess(t)
    yaml = ready
    opt = OptionParser.new
    yaml.parse(opt)
    opt.parse ["--guess-time=0"]
    yaml.head

    expects = [
      [100, 200, nil],
      [nil, 500, 600],
      nil, nil, nil, nil, nil
    ].each do |expect|
      actual = yaml.gets
      if actual != expect
        t.error("expect #{expect} got #{actual}")
      end
    end
  end

  def test_gets_with_prekeys(t)
    yaml = ready
    opt = OptionParser.new
    yaml.parse(opt)
    opt.parse ["--key=bar,foo"]
    yaml.head

    expects = [
      [200, 100],
      [500, nil],
      nil, nil, nil, nil, nil
    ].each do |expect|
      actual = yaml.gets
      if actual != expect
        t.error("expect #{expect} got #{actual}")
      end
    end
  end

  def test_e2e(t)
    actual = `ruby -ryaml -e '3.times { [{"a"=>1},{"b"=>2},{"c"=>3}].each{|h| puts YAML.dump(h)} }' | bundle ex kor yaml --guess-time=3 csv`
    expect = <<-CSV
a,b,c
1,,
,2,
,,3
1,,
,2,
,,3
1,,
,2,
,,3
CSV
    if actual != expect
      t.error("expect #{expect.inspect} got #{actual.inspect}")
    end
  end

  private

  def go
    [yield, nil]
  rescue Exception => err
    [nil, err]
  end
end
