$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'label_context_model'

describe LabelContextModel do

  subject { LabelContextModel.new }

  it "works" do
    subject.add_sentence_with_labels(%w(i like big red dogs),["red dogs"])
    subject.add_sentence_with_labels(%w(i like small red dogs),["red dogs"])
    subject.add_sentence_with_labels(%w(big yellow cats are cool),["yellow cats", "cool"])

    dists = subject.compute_label_distributions()
    dists.each do |label, dist|
      dists[label].each do |word, score|
        dists[label][word] = score.round(2)
      end
    end
    dists.should == {
        "red dogs"=>
            {"i"=>-0.11, "like"=>-0.11, "big"=>-0.51, "red"=>-0.11, "dogs"=>-0.11, "small"=>0.18, "yellow"=>-0.51, "cats"=>-0.51, "are"=>-0.51, "cool"=>-0.51},
        "yellow cats"=>
            {"i"=>-0.51, "like"=>-0.51, "big"=>0.18, "red"=>-0.51, "dogs"=>-0.51, "small"=>0.18, "yellow"=>0.88, "cats"=>0.88, "are"=>0.88, "cool"=>0.88},
        "cool"=>{"i"=>-0.51, "like"=>-0.51, "big"=>0.18, "red"=>-0.51, "dogs"=>-0.51, "small"=>0.18, "yellow"=>0.88, "cats"=>0.88, "are"=>0.88, "cool"=>0.88}
    }

  end

  it "works2" do
    subject.add_sentence_with_labels(%w(i like cool big red dogs),["red dogs", "cool"])
    subject.add_sentence_with_labels(%w(i like small red dogs),["red dogs"])
    subject.add_sentence_with_labels(%w(big yellow cats are cool),["yellow cats", "cool"])

    dists = subject.compute_label_distributions()
    dists.each do |label, dist|
      dists[label].each do |word, score|
        dists[label][word] = score.round(2)
      end
    end
    dists.should == {
        "red dogs"=>{"i"=>0.05, "like"=>0.05, "cool"=>-0.35, "big"=>-0.35, "red"=>0.05, "dogs"=>0.05, "small"=>0.34, "yellow"=>-0.35, "cats"=>-0.35, "are"=>-0.35},
        "cool"=>{"i"=>-0.35, "like"=>-0.35, "cool"=>0.05, "big"=>0.05, "red"=>-0.35, "dogs"=>-0.35, "small"=>-0.35, "yellow"=>0.34, "cats"=>0.34, "are"=>0.34},
        "yellow cats"=>{"i"=>-0.35, "like"=>-0.35, "cool"=>0.34, "big"=>0.34, "red"=>-0.35, "dogs"=>-0.35, "small"=>0.34, "yellow"=>1.03, "cats"=>1.03, "are"=>1.03}
    }

  end

end