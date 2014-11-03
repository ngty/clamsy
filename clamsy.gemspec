# -*- encoding: utf-8 -*-
# stub: clamsy 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "clamsy"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["NgTzeYang"]
  s.date = "2010-05-19"
  s.description = "Ruby wrapper for generating a single pdf for multiple contexts from an odt template."
  s.email = "ngty77@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = [".document", ".gitignore", "HISTORY.txt", "LICENSE", "README.rdoc", "Rakefile", "VERSION", "clamsy.gemspec", "clamsy.png", "examples/create_many.rb", "examples/create_one.rb", "examples/data/context.rb", "examples/data/contexts.rb", "examples/data/school_logo.jpg", "examples/data/staff_signature.gif", "examples/data/student_offer_letter.odt", "examples/tmp/dummy", "lib/clamsy.rb", "lib/clamsy.yml", "lib/clamsy/base_printer.rb", "lib/clamsy/configuration.rb", "lib/clamsy/cups_pdf_printer.rb", "lib/clamsy/file_system_support.rb", "lib/clamsy/jod_converter_printer.rb", "lib/clamsy/template_open_doc.rb", "lib/clamsy/tenjin.rb", "lib/jodconverter/CREDIT", "lib/jodconverter/LICENSE.txt", "lib/jodconverter/README.txt", "lib/jodconverter/commons-cli-1.2.jar", "lib/jodconverter/commons-io-1.4.jar", "lib/jodconverter/jodconverter-2.2.2.jar", "lib/jodconverter/jodconverter-cli-2.2.2.jar", "lib/jodconverter/juh-3.0.1.jar", "lib/jodconverter/jurt-3.0.1.jar", "lib/jodconverter/ridl-3.0.1.jar", "lib/jodconverter/slf4j-api-1.5.6.jar", "lib/jodconverter/slf4j-jdk14-1.5.6.jar", "lib/jodconverter/unoil-3.0.1.jar", "lib/jodconverter/xstream-1.3.1.jar", "spec/clamsy/base_printer_spec.rb", "spec/clamsy/configuration_spec.rb", "spec/clamsy/cups_pdf_printer_spec.rb", "spec/clamsy/data/clamsy.png", "spec/clamsy/data/clamsy2.png", "spec/clamsy/data/embedded_ruby_after.odt", "spec/clamsy/data/embedded_ruby_before.odt", "spec/clamsy/data/escaped_text_after.odt", "spec/clamsy/data/escaped_text_before.odt", "spec/clamsy/data/invalid_content_example.odt", "spec/clamsy/data/invalid_zip_example.odt", "spec/clamsy/data/multiple_contexts_after.odt", "spec/clamsy/data/multiple_contexts_before.odt", "spec/clamsy/data/picture_after.odt", "spec/clamsy/data/picture_before.odt", "spec/clamsy/data/plain_text_after.odt", "spec/clamsy/data/plain_text_before.odt", "spec/clamsy/file_system_support_spec.rb", "spec/clamsy/invalid_printer_spec.rb", "spec/clamsy/jod_converter_printer_spec.rb", "spec/clamsy/template_open_doc_spec.rb", "spec/fake_ooffice_server.rb", "spec/integration/cups_pdf_printer_spec.rb", "spec/integration/data/embedded_ruby_example.odt", "spec/integration/data/embedded_ruby_example.pdf", "spec/integration/data/escaped_text_example.odt", "spec/integration/data/escaped_text_example.pdf", "spec/integration/data/multiple_contexts_example.odt", "spec/integration/data/multiple_contexts_example.pdf", "spec/integration/data/norm_clamsy.png", "spec/integration/data/picture_example.odt", "spec/integration/data/picture_example.pdf", "spec/integration/data/plain_text_example.odt", "spec/integration/data/plain_text_example.pdf", "spec/integration/data/sunny_clamsy.png", "spec/integration/has_integration_support_shared_spec.rb", "spec/integration/jod_converter_printer_spec.rb", "spec/pdfc/CCLib.jar", "spec/pdfc/CREDIT", "spec/pdfc/PDFC.bat", "spec/pdfc/PDFC.jar", "spec/pdfc/PDFC.sh", "spec/pdfc/PDFParser.jar", "spec/pdfc/config.xml", "spec/pdfc/license/LICENSE.log4j", "spec/pdfc/license/lgpl-3.0.txt", "spec/pdfc/license/overview.txt", "spec/pdfc/log4j-1.2.15.jar", "spec/pdfc/readme.txt", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/ngty/clamsy"
  s.post_install_message = "\n  ///////////////////////////////////////////////////////////////////////////////////////////////////\n\n    :: CLAMSY ::\n\n    Thank you for installing clamsy-0.0.5.\n\n    Starting from this release, the default printer has been changed from 'cups_pdf' to\n    'jod_convertor'. If java is in your PATH, and openoffice is installed the standard way,\n    most probably, no additional action is required after this gem installation.\n\n    We are in the process of constructing the clamsy wiki @ http://wiki.github.com/ngty/clamsy, pls\n    take a look there for solution(s) to your problem(s).\n\n    Alternatively, you may wish to post ur problem @ http://github.com/ngty/clamsy/issues.\n\n    Have a nice day !!\n\n  ///////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubygems_version = "2.4.1"
  s.summary = "Clamsy makes PDF generation simple"
  s.test_files = ["spec/fake_ooffice_server.rb", "spec/integration/jod_converter_printer_spec.rb", "spec/integration/cups_pdf_printer_spec.rb", "spec/integration/has_integration_support_shared_spec.rb", "spec/clamsy/file_system_support_spec.rb", "spec/clamsy/base_printer_spec.rb", "spec/clamsy/jod_converter_printer_spec.rb", "spec/clamsy/cups_pdf_printer_spec.rb", "spec/clamsy/invalid_printer_spec.rb", "spec/clamsy/configuration_spec.rb", "spec/clamsy/template_open_doc_spec.rb", "spec/spec_helper.rb", "examples/create_many.rb", "examples/data/contexts.rb", "examples/data/context.rb", "examples/create_one.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyzip>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<rghost>, [">= 0.8.7.2"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.1"])
      s.add_development_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_development_dependency(%q<eventmachine>, [">= 0.12.10"])
    else
      s.add_dependency(%q<rubyzip>, [">= 0.9.4"])
      s.add_dependency(%q<rghost>, [">= 0.8.7.2"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.1"])
      s.add_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
    end
  else
    s.add_dependency(%q<rubyzip>, [">= 0.9.4"])
    s.add_dependency(%q<rghost>, [">= 0.8.7.2"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.1"])
    s.add_dependency(%q<bacon>, [">= 1.1.0"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
  end
end
