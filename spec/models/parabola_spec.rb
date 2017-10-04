require_relative('../../spec/spec_helper')
require_relative('../../models/parabola')

describe Parabola do

  describe '.new' do

    context 'invalid parameters' do

      it 'should fail when line' do
        expect {
          described_class.new(x2: 0, x: 1, k: 1)
        }.to raise_error(ArgumentError, 'Invalid coefficients!')
      end

    end

    it 'should be the simplest parabola' do
      parabola = described_class.new(x2: 1, x: 0, k: 0)

      expect(parabola.focus).to eq(Point.create(x: 0, y: '1/4'))
      expect(parabola.vertex).to eq(Point.origin)
      expect(parabola.directrix).to eq(Line.horizontal(known_term: '-1/4'))
      expect(parabola.symmetry_axis).to eq(Line.y_axis)
    end

    it 'should be the generic parabola' do
      parabola = described_class.new(x2: -2, x: 3, k: -4)

      expect(parabola.focus).to eq(Point.create(x: '3/4', y: -3))
      expect(parabola.vertex).to eq(Point.create(x: '3/4', y: '-23/8'))
      expect(parabola.directrix).to eq(Line.horizontal(known_term: '-11/4'))
      expect(parabola.symmetry_axis).to eq(Line.vertical(known_term: '3/4'))
    end

  end

  describe '.unitary_convex' do

    it 'should be the unitary convex parabola' do
      parabola = described_class.unitary_convex

      expect(parabola.focus).to eq(Point.create(x: 0, y: '1/4'))
      expect(parabola.vertex).to eq(Point.origin)
      expect(parabola.directrix).to eq(Line.horizontal(known_term: '-1/4'))
      expect(parabola.symmetry_axis).to eq(Line.y_axis)
    end

  end

  describe '.unitary_concave' do

    it 'should be the unitary concave parabola' do
      parabola = described_class.unitary_concave

      expect(parabola.focus).to eq(Point.create(x: 0, y: '-1/4'))
      expect(parabola.vertex).to eq(Point.origin)
      expect(parabola.directrix).to eq(Line.horizontal(known_term: '1/4'))
      expect(parabola.symmetry_axis).to eq(Line.y_axis)
    end

  end

  describe '#unitary_convex?' do

    it 'should be false' do
      parabola = described_class.unitary_concave

      expect(
          parabola.unitary_convex?
      ).to be_falsey
    end

    it 'should be true' do
      parabola = described_class.unitary_convex

      expect(
          parabola.unitary_convex?
      ).to be_truthy
    end

  end

  describe '#unitary_concave?' do

    it 'should be false' do
      parabola = described_class.unitary_convex

      expect(
          parabola.unitary_concave?
      ).to be_falsey
    end

    it 'should be true' do
      parabola = described_class.unitary_concave

      expect(
          parabola.unitary_concave?
      ).to be_truthy
    end

  end

  describe '#==' do

    it 'should be false when not parabola' do
      expect(
          described_class.unitary_convex == NilClass
      ).to be_falsey
    end

    it 'should be false when different focus' do
    end

    it 'should be false when different directrix' do
    end

    it 'should be true' do
      parabola1 = described_class.unitary_convex
      parabola2 = described_class.unitary_convex

      expect(
          parabola1 == parabola2
      ).to be_truthy
    end

  end


end