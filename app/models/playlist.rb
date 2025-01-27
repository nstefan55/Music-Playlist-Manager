require 'json'

require_relative '../utils/formatLength'


class Playlist
  attr_accessor :naziv, :pjesme

  def initialize(naziv)
    raise ArgumentError, "Naziv ne može biti nil ili prazan!" if naziv.nil? || naziv.empty?
    @naziv = naziv
    @pjesme = []
  end

  def dodajPjesmu(pjesma)
    case
    when @pjesme.any? { |p| p.naziv == pjesma.naziv && p.album == pjesma.album }
      "Pjesma s istim nazivom i albumom već postoji u playlisti"
    when @pjesme.any? { |p| p.naziv == pjesma.naziv }
      "Pjesma s istim nazivom već postoji u playlisti"
    else
      @pjesme << pjesma
      "Pjesma uspješno dodana u playlistu"
    end
  end

  def obrisiPjesmu(nazivPjesme)
    if @pjesme.any? { |p| p.naziv == nazivPjesme }
      @pjesme.delete_if { |p| p.naziv == nazivPjesme }
      "Pjesma uspješno obrisana iz playliste"
    else
      "Pjesma ne postoji u playlisti"
    end
  end

  def detaljiPlayliste
    brojPjesama = @pjesme.size
    ukupnoTrajanje = @pjesme.sum(&:trajanje)
    formatiranoTrajanje = formatTrajanje(ukupnoTrajanje)
    "Broj pjesama: #{brojPjesama}, Ukupno trajanje: #{formatiranoTrajanje}"
  end

  def urediNaziv(noviNaziv)
    raise ArgumentError, "Novi naziv ne može biti nil ili prazan!" if noviNaziv.nil? || noviNaziv.empty?
    @naziv = noviNaziv
    puts "Naziv playliste uspješno promijenjen."
  end
end
