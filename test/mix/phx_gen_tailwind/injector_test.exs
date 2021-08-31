defmodule Mix.Phx.Gen.Tailwind.InjectorTest do
  use ExUnit.Case, async: true

  alias Mix.Phx.Gen.Tailwind.Injector

  describe "css_import_inject/1" do
    test "handles phoenix.css import existing" do
      input = """
      /* This file is for your main application CSS */
      @import "./phoenix.css";

      /* Alerts and form errors used by phx.new */
      """

      {:ok, injected} = Injector.css_import_inject(input)

      assert injected === """
             /* This file is for your main application CSS */
             @import "tailwindcss/base";
             @import "tailwindcss/components";
             @import "tailwindcss/utilities";


             /* Alerts and form errors used by phx.new */
             """
    end

    test "handles no phoenix.css import or initial comment" do
      input = """
      /* Alerts and form errors used by phx.new */
      .alert {
        padding: 15px;
        margin-bottom: 20px;
        border: 1px solid transparent;
        border-radius: 4px;
      }
      """

      {:ok, injected} = Injector.css_import_inject(input)

      assert injected === """
             @import "tailwindcss/base";
             @import "tailwindcss/components";
             @import "tailwindcss/utilities";
             /* Alerts and form errors used by phx.new */
             .alert {
               padding: 15px;
               margin-bottom: 20px;
               border: 1px solid transparent;
               border-radius: 4px;
             }
             """
    end

    test "handles empty file" do
      input = ""

      {:ok, injected} = Injector.css_import_inject(input)

      assert injected ===
               """
               @import "tailwindcss/base";
               @import "tailwindcss/components";
               @import "tailwindcss/utilities";
               """
    end

    test "handles injected code already present" do
      input = """
      /* This file is for your main application CSS */
      @import "tailwindcss/base";
      @import "tailwindcss/components";
      @import "tailwindcss/utilities";

      /* Alerts and form errors used by phx.new */
      """

      assert :already_injected == Injector.css_import_inject(input)
    end
  end
end
