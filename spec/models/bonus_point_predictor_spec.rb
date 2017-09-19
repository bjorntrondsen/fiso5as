require 'spec_helper'

describe BonusPointPredictor do
  it "should return element ids and bonus points" do
    data = {"bps"=>{"a"=>[{"value"=>46, "element"=>271}, {"value"=>45, "element"=>282}, {"value"=>42, "element"=>281}, {"value"=>30, "element"=>264}, {"value"=>29, "element"=>270}, {"value"=>29, "element"=>285}, {"value"=>27, "element"=>267}, {"value"=>22, "element"=>260}, {"value"=>19, "element"=>107}, {"value"=>19, "element"=>280}, {"value"=>17, "element"=>274}, {"value"=>3, "element"=>275}, {"value"=>2, "element"=>278}, {"value"=>2, "element"=>284}], "h"=>[{"value"=>17, "element"=>367}, {"value"=>16, "element"=>350}, {"value"=>14, "element"=>352}, {"value"=>14, "element"=>485}, {"value"=>11, "element"=>354}, {"value"=>10, "element"=>358}, {"value"=>10, "element"=>370}, {"value"=>10, "element"=>373}, {"value"=>8, "element"=>357}, {"value"=>8, "element"=>365}, {"value"=>3, "element"=>372}, {"value"=>2, "element"=>369}, {"value"=>1, "element"=>360}, {"value"=>-1, "element"=>374}]}}
    expect(BonusPointPredictor.predict(data)).to eq({
      271 => 3,
      282 => 2,
      281 => 1,
    })
  end

  it "should determine duplicate 1 pointers" do
    data = {"bps"=>{"a"=>[{"value"=>46, "element"=>271}, {"value"=>45, "element"=>282}, {"value"=>42, "element"=>281}, {"value"=>30, "element"=>264}, {"value"=>29, "element"=>270}, {"value"=>29, "element"=>285}, {"value"=>27, "element"=>267}, {"value"=>22, "element"=>260}, {"value"=>19, "element"=>107}, {"value"=>19, "element"=>280}, {"value"=>17, "element"=>274}, {"value"=>3, "element"=>275}, {"value"=>2, "element"=>278}, {"value"=>2, "element"=>284}], "h"=>[{"value"=>42, "element"=>367}, {"value"=>42, "element"=>350}, {"value"=>14, "element"=>352}, {"value"=>14, "element"=>485}, {"value"=>11, "element"=>354}, {"value"=>10, "element"=>358}, {"value"=>10, "element"=>370}, {"value"=>10, "element"=>373}, {"value"=>8, "element"=>357}, {"value"=>8, "element"=>365}, {"value"=>3, "element"=>372}, {"value"=>2, "element"=>369}, {"value"=>1, "element"=>360}, {"value"=>-1, "element"=>374}]}}
    expect(BonusPointPredictor.predict(data)).to eq({
      271 => 3,
      282 => 2,
      281 => 1,
      367 => 1,
      350 => 1,
    })
  end

  it "should determine duplicate 2 pointers" do
    data = {"bps"=>{"a"=>[{"value"=>46, "element"=>271}, {"value"=>45, "element"=>282}, {"value"=>42, "element"=>281}, {"value"=>30, "element"=>264}, {"value"=>29, "element"=>270}, {"value"=>29, "element"=>285}, {"value"=>27, "element"=>267}, {"value"=>22, "element"=>260}, {"value"=>19, "element"=>107}, {"value"=>19, "element"=>280}, {"value"=>17, "element"=>274}, {"value"=>3, "element"=>275}, {"value"=>2, "element"=>278}, {"value"=>2, "element"=>284}], "h"=>[{"value"=>45, "element"=>367}, {"value"=>16, "element"=>350}, {"value"=>14, "element"=>352}, {"value"=>14, "element"=>485}, {"value"=>11, "element"=>354}, {"value"=>10, "element"=>358}, {"value"=>10, "element"=>370}, {"value"=>10, "element"=>373}, {"value"=>8, "element"=>357}, {"value"=>8, "element"=>365}, {"value"=>3, "element"=>372}, {"value"=>2, "element"=>369}, {"value"=>1, "element"=>360}, {"value"=>-1, "element"=>374}]}}
    expect(BonusPointPredictor.predict(data)).to eq({
      271 => 3,
      282 => 2,
      367 => 2,
    })
  end

  it "should determine duplicate 3 pointers" do
    data = {"bps"=>{"a"=>[{"value"=>46, "element"=>271}, {"value"=>46, "element"=>282}, {"value"=>42, "element"=>281}, {"value"=>30, "element"=>264}, {"value"=>29, "element"=>270}, {"value"=>29, "element"=>285}, {"value"=>27, "element"=>267}, {"value"=>22, "element"=>260}, {"value"=>19, "element"=>107}, {"value"=>19, "element"=>280}, {"value"=>17, "element"=>274}, {"value"=>3, "element"=>275}, {"value"=>2, "element"=>278}, {"value"=>2, "element"=>284}], "h"=>[{"value"=>46, "element"=>367}, {"value"=>46, "element"=>350}, {"value"=>46, "element"=>352}, {"value"=>14, "element"=>485}, {"value"=>11, "element"=>354}, {"value"=>10, "element"=>358}, {"value"=>10, "element"=>370}, {"value"=>10, "element"=>373}, {"value"=>8, "element"=>357}, {"value"=>8, "element"=>365}, {"value"=>3, "element"=>372}, {"value"=>2, "element"=>369}, {"value"=>1, "element"=>360}, {"value"=>-1, "element"=>374}]}}
    expect(BonusPointPredictor.predict(data)).to eq({
      271 => 3,
      282 => 3,
      367 => 3,
      350 => 3,
      352 => 3,
    })
  end

  it "should skip 2 pointers if there are 2 x 3 pointers" do
    data = {"bps"=>{"a"=>[{"value"=>46, "element"=>271}, {"value"=>46, "element"=>282}, {"value"=>42, "element"=>281}, {"value"=>30, "element"=>264}, {"value"=>29, "element"=>270}, {"value"=>29, "element"=>285}, {"value"=>27, "element"=>267}, {"value"=>22, "element"=>260}, {"value"=>19, "element"=>107}, {"value"=>19, "element"=>280}, {"value"=>17, "element"=>274}, {"value"=>3, "element"=>275}, {"value"=>2, "element"=>278}, {"value"=>2, "element"=>284}], "h"=>[{"value"=>17, "element"=>367}, {"value"=>16, "element"=>350}, {"value"=>14, "element"=>352}, {"value"=>14, "element"=>485}, {"value"=>11, "element"=>354}, {"value"=>10, "element"=>358}, {"value"=>10, "element"=>370}, {"value"=>10, "element"=>373}, {"value"=>8, "element"=>357}, {"value"=>8, "element"=>365}, {"value"=>3, "element"=>372}, {"value"=>2, "element"=>369}, {"value"=>1, "element"=>360}, {"value"=>-1, "element"=>374}]}}
    expect(BonusPointPredictor.predict(data)).to eq({
      271 => 3,
      282 => 3,
      281 => 1,
    })
  end
end
