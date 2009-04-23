#
# Test for unsafe extention
#
require 'test/unit'
require 'yarv2llvm'

class UnsafeTests < Test::Unit::TestCase
=begin
  def test_unsafe
    YARV2LLVM::compile(<<-EOS, {:disasm => true, :dump_yarv => true, :optimize=> true})
def tunsafe
  type = LLVM::struct([RubyHelpers::VALUE, LLVM::Type::Int32Ty, RubyHelpers::VALUE, RubyHelpers::VALUE])
  a = [:a, :b]
  foo = YARV2LLVM::LLVMLIB::unsafe(a, type)
  YARV2LLVM::LLVMLIB::safe(foo[2])
end

def tunsafe2
  type = LLVM::struct([RubyHelpers::VALUE, LLVM::Type::Int32Ty, RubyHelpers::VALUE, RubyHelpers::VALUE])
  a = [:a, :b]
  foo = YARV2LLVM::LLVMLIB::unsafe(a, type)
  foo[2] = YARV2LLVM::LLVMLIB::unsafe(:c, RubyHelpers::VALUE)
  YARV2LLVM::LLVMLIB::safe(foo[2])
end
EOS
    assert_equal(tunsafe, :a)
    assert_equal(tunsafe2, :c)
  end

  def test_define_external_function
    YARV2LLVM::compile(<<-EOS, {:disasm => true, :dump_yarv => true, :optimize=> true, :func_signature => true})
def tdefine_external_function
  value = RubyHelpers::VALUE
  int32ty = LLVM::Type::Int32Ty
  type = LLVM::function(value, [int32ty])
  YARV2LLVM::LLVMLIB::define_external_function(:rb_ary_new2, 
                                               'rb_ary_new2', 
                                               type)
  
  siz = YARV2LLVM::LLVMLIB::unsafe(2, int32ty)
  YARV2LLVM::LLVMLIB::safe(rb_ary_new2(siz))
end
EOS
    assert_equal(tdefine_external_function, [])
  end
=end
  def test_define_macro
    YARV2LLVM::compile(<<-'EOS', {:disasm => false, :dump_yarv => false, :optimize=> true, :func_signature => false})
YARV2LLVM::define_macro :myif do |arg| `if #{para[:args][2]} then #{para[:args][1]} else #{para[:args][0]} end` end

def tdefine_macro
  myif(true, p("foo"), p("bar"))
end
EOS
    assert_equal(tdefine_macro, "hello")
  end

end