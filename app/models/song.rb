class Song
    attr_accessor :naziv, :izvodac, :album, :trajanje

    def initialize(naziv, izvodac, album, trajanje)
        @naziv = naziv
        @izvodac = izvodac
        @album = album
        @trajanje = trajanje
    end

    def detaljiPjesme
        [@naziv, @izvodac, @album, @trajanje]
    end
end

