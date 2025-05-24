module NameNormalizer
  module_function

  def normalize_name(name)
    return '' unless name
    name.downcase
        .gsub(/\s+/, ' ')
        .strip
        .gsub(/[éèêë]/, 'e')
        .gsub(/[áàâä]/, 'a')
        .gsub(/[íìîï]/, 'i')
        .gsub(/[óòôö]/, 'o')
        .gsub(/[úùûü]/, 'u')
        .gsub(/[ýỳŷÿ]/, 'y')
        .gsub(/[ñ]/, 'n')
        .gsub(/[ç]/, 'c')
  end
end