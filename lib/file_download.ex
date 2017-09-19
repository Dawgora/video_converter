defmodule FileDownload do
import FFmpex
use FFmpex.Options

  def download (link) do
      {_, 0} = System.cmd("youtube-dl", [link, "-odownloaded/example.%(ext)s", "-q", "-f 22"])
      location = File.cwd! <> "/downloaded"
      {:ok, file_names} = location |> File.ls
      file_location = location <> "/" <> hd(file_names)

      command = FFmpex.new_command
      |> add_global_option(option_y())
      |> add_input_file(file_location)
      |> add_output_file(File.cwd! <> "/output/output.webm")
      |> add_file_option(option_maxrate("128k"))
      |> add_file_option(option_bufsize("64k"))


      :ok = execute(command)

      File.rm!(file_location)
      
      IO.puts "webm created successfully"
  end
end
