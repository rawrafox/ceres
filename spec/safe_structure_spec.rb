require 'spec_helper'

module SafeStructureSpec
  class A < SafeStructure
    attribute :a, type: String
  end

  class B < SafeStructure
    attribute :a, type: String
    attribute :b, type: Fixnum, default: 1

    equality :a
  end

  class C < B
    attribute :a, default: 'c'
  end

  class D < SafeStructure
    attribute :a, enum: [:a, :b, :c]
  end

  class E < SafeStructure
    attribute :a, optional: true
  end

  class F < SafeStructure
    array :a, element_type: String
  end
end

RSpec.describe SafeStructure do
  it 'has a version number' do
    expect(SafeStructure::VERSION).not_to be nil
  end

  context 'attributes' do
    it 'initializes attributes' do
      expect(SafeStructureSpec::A.new(a: 'a').a).to eq('a')
    end

    it 'initializes array attributes' do
      expect(SafeStructureSpec::F.new(a: ['a']).a).to eq(['a'])
    end

    it 'initializes multiple attributes' do
      v = SafeStructureSpec::B.new(a: 'a', b: 1)

      expect(v.a).to eq('a')
      expect(v.b).to eq(1)
    end

    it 'raises InvalidArgument if array attribute is not array' do
      expect { SafeStructureSpec::F.new(a: 1) }.to raise_error(ArgumentError)
    end

    it 'raises InvalidArgument if extra attribute is provided' do
      expect { SafeStructureSpec::A.new(a: 1, b: 2) }.to raise_error(ArgumentError)
    end
  end

  context 'definitions' do
    it 'does not allow overwriting attributes in same class' do
      expect do
        Class.new(SafeStructure) do
          attribute :a
          attribute :a
        end
      end.to raise_error(ArgumentError)
    end
  end

  context 'default' do
    it 'fills in attribute with default' do
      v = SafeStructureSpec::B.new(a: 'a')

      expect(v.a).to eq('a')
      expect(v.b).to eq(1)
    end

    it 'raises InvalidArgument if there is no default' do
      expect { SafeStructureSpec::A.new }.to raise_error(ArgumentError)
    end
  end

  context 'element_type' do
    it 'initializes attribute if elements are of correct type' do
      expect(SafeStructureSpec::F.new(a: ['a']).a).to eq(['a'])
    end

    it 'raises InvalidArgument if value is not in enum' do
      expect { SafeStructureSpec::F.new(a: [:a]) }.to raise_error(ArgumentError)
    end
  end

  context 'enum' do
    it 'initializes attribute if value is in enum' do
      expect(SafeStructureSpec::D.new(a: :a).a).to eq(:a)
    end

    it 'raises InvalidArgument if value is not in enum' do
      expect { SafeStructureSpec::D.new(a: :d) }.to raise_error(ArgumentError)
    end
  end

  context 'equality' do
    it 'compares equal if the same class' do
      a = SafeStructureSpec::B.new(a: 'a')
      b = SafeStructureSpec::B.new(a: 'a')

      expect(a).to eq(b)
      expect(a.hash).to eq(b.hash)
    end

    it 'does not compare equal if different classes' do
      a = SafeStructureSpec::B.new(a: 'a')
      b = SafeStructureSpec::C.new(a: 'a')

      expect(a).not_to eq(b)
      expect(a.hash).not_to eq(b.hash)
    end

    it 'compares only the attributes defined' do
      a = SafeStructureSpec::C.new(a: 'a')
      b = SafeStructureSpec::C.new(a: 'a', b: 4)

      expect(a).to eq(b)
      expect(a.hash).to eq(b.hash)
    end
  end

  context 'inheritance' do
    it 'inherits attributes' do
      v = SafeStructureSpec::C.new(a: 'a', b: 1)

      expect(v.a).to eq('a')
      expect(v.b).to eq(1)
    end

    it 'overrides options' do
      v = SafeStructureSpec::C.new(b: 1)

      expect(v.a).to eq('c')
      expect(v.b).to eq(1)
    end
  end

  context 'optional' do
    it 'allows nil if optional' do
      expect(SafeStructureSpec::E.new(a: nil).a).to eq(nil)
    end

    it 'allows default to be nil if optional' do
      expect(SafeStructureSpec::E.new.a).to eq(nil)
    end

    it 'raises InvalidArgument if attribute is not optional' do
      expect { SafeStructureSpec::A.new(a: nil) }.to raise_error(ArgumentError)
    end
  end

  context 'type' do
    it 'initializes attribute if value has correct type' do
      expect(SafeStructureSpec::A.new(a: 'a').a).to eq('a')
    end

    it 'raises InvalidArgument if type is wrong' do
      expect { SafeStructureSpec::A.new(a: 1) }.to raise_error(ArgumentError)
    end
  end
end
