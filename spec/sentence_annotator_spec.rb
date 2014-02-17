$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'sentence_annotator'


describe SentenceAnnotator do

  let(:annotator) { SentenceAnnotator.new }
  
  context "with a simple sentence" do
    subject { annotator.parse("I love fish!") }

    it { subject.length.should == 1 }
    it { subject[0].raw.should == "I love fish!" }
    it { subject[0].tokens.should == %w[i love fish] }
    it { subject[0].pos.should == %w[PRP VBP NN] }
  end

  context "with two simple sentences" do
    subject { annotator.parse("I love fish. We are cool.") }
    
    it { subject.length.should == 2 }
    it { subject[0].raw.should == "I love fish." }
    it { subject[1].raw.should == "We are cool." }
  end
  
  context "with a tricky sentence" do
    subject { annotator.parse("Mrs. Jones is lovely.") }

    it { subject.length.should == 1 }
  end

  context "with two tricky sentences" do
    subject { annotator.parse('I said to the stranger, "Who are you?" "My name is George," he said.') }

    it { subject.length.should == 2 }
    it { subject[0].raw.should == 'I said to the stranger, "Who are you?"' }
    it { subject[1].raw.should == '"My name is George," he said.' }
  end

  context "with a url" do
    subject { annotator.parse("Together with Victor de Lorenzo he created the free and open access journal Symplectic Biology, devoted to publishing innovative ideas in systems and synthetic biology http://knol.google.com/k/symplectic-biology#") }
    it { subject.length.should == 1 }
  end
end
