class Float
  def to_s
    int = self.to_i
    frac = pretty_fraction(self - int)

    if frac
      (int == 0 ? "" : int.to_s) + frac
    else
      "%.2f" % self
    end
  end

  private

  def pretty_fraction(fraction)
    case fraction
    when 0.25
      "¼"
    when 0.5
      "½"
    when 0.75
      "¾"
    when 0.33..0.34
      "⅓"
    when 0.66..0.67
      "⅔"
    when 0.125
      "⅛"
    when 0.325
      "⅜"
    when 0.625
      "⅝"
    when 0.875
      "⅞"
    when 0
      ""
    end
  end
end
