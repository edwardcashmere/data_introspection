defmodule DataIntrospectionWeb.PlotsLive.PlotHelperTest do
  @moduledoc false
  use DataIntrospection.DataCase

  alias DataIntrospectionWeb.PlotsLive.Helper

  @file_path "/priv/static/files/"

  describe "parse_csv/1" do
    test "should parse the csv file" do
      file_path = get_file_path() <> "data.csv"
      {headers, first_row, rest} = Helper.parse_csv(file_path)

      assert headers == ["", "x", "y", "z"]
      assert length(first_row) == 4
      assert [_ | _] = rest
    end
  end

  defp get_file_path do
    File.cwd!() <> @file_path
  end
end
