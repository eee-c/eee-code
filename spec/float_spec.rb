require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

describe Float, "pretty printing" do
  specify "1.23.to_s == '1.23'" do
    1.23.to_s.should == "1.23"
  end
  specify "1.236.to_s == '1.24'" do
    1.236.to_s.should == "1.24"
  end
  specify "0.25.to_s == '¼'" do
    0.25.to_s.should == "¼"
  end
  specify "0.5.to_s == '½'" do
    0.5.to_s.should == "½"
  end
  specify "0.75.to_s == '¾'" do
    0.75.to_s.should == "¾"
  end
  specify "0.33.to_s == '⅓'" do
    0.33.to_s.should == "⅓"
  end
  specify "0.333.to_s == '⅓'" do
    0.333.to_s.should == "⅓"
  end
  specify "0.66.to_s == '⅔'" do
    0.66.to_s.should == "⅔"
  end
  specify "0.667.to_s == '⅔'" do
    0.667.to_s.should == "⅔"
  end
  specify "0.125.to_s == '⅛'" do
    0.125.to_s.should == "⅛"
  end
  specify "0.325.to_s == '⅜'" do
    0.325.to_s.should == "⅜"
  end
  specify "0.625.to_s == '⅝'" do
    0.625.to_s.should == "⅝"
  end
  specify "0.875.to_s == '⅞'" do
    0.875.to_s.should == "⅞"
  end
  specify "1.0.to_s == '1'" do
    1.0.to_s.should == "1"
  end
end
