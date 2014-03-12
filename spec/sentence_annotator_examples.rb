shared_examples_for "a sentence annotator" do

  def parse(text)
    parsed = annotator.parse([[0,text]]).to_a
    parsed[0][1]
  end

  context "with a simple sentence" do
    subject { parse("I love fish!") }

    it { subject.length.should == 1 }
    it { subject[0].raw.should == "I love fish!" }
    it { subject[0].tokens.should == %w[i love fish] }
    #it { subject[0].pos.should == %w[PRP VBP NN] }
  end

  context "with two simple sentences" do
    subject { parse("I love fish. We are cool.") }

    it { subject.length.should == 2 }
    it { subject[0].raw.should == "I love fish." }
    it { subject[1].raw.should == "We are cool." }
  end

  context "with a tricky sentence" do
    subject { parse("Mrs. Jones is lovely.") }

    it { subject.length.should == 1 }
  end

  context "with two tricky sentences" do
    subject { parse("I said to the stranger, Who are you?\n\"My name is George,\" he said.") }

    it { subject.length.should == 2 }
    it { subject[0].raw.should == 'I said to the stranger, Who are you?' }
    it { subject[1].raw.should == '"My name is George," he said.' }
  end

  context "with a url" do
    subject { parse("Together with Victor de Lorenzo he created the free and open access journal Symplectic Biology, devoted to publishing innovative ideas in systems and synthetic biology http://knol.google.com/k/symplectic-biology#.") }
    it { subject.length.should == 1 }
  end

  context "with a reused annotator" do
    let(:parse1) { parse("I love fish.") }
    let(:parse2) { parse("We are cool.") }

    it { parse1.length.should == 1 }
    it { parse1[0].raw.should == "I love fish." }
    it { parse2.length.should == 1 }
    it { parse2[0].raw.should == "We are cool."}
  end

end