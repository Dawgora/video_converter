defmodule FileDownload do
import FFmpex
use FFmpex.Options

  def download(link, quality \\ 22, start, final, format \\ :webm) do
      quality
      {_, 0} = System.cmd("youtube-dl", [link, "-odownloaded/example.%(ext)s", "-q", "-f " <> quality])
      location = File.cwd! <> "/downloaded"
      {:ok, file_names} = location |> File.ls
      file_location = location <> "/" <> hd(file_names)

      convert_video file_location, start, final, format
      

      File.rm!(file_location)

      IO.puts Atom.to_string(format) <>" created successfully"
  end

  def get_quality(link) do
    {formats, 0} = System.cmd("youtube-dl", [link, "-F"])
    formats |> String.split(["\n"])
  end

  defp convert_video(file_location, start, final, format) do
      command = FFmpex.new_command
      |> add_global_option(option_y())
      |> add_input_file(file_location)
      |> create_from_format(format, start, final)
      |> add_file_option(option_maxrate("128k"))
      |> add_file_option(option_bufsize("64k"))


      :ok = execute(command)
  end

  defp create_from_format(stuff, format, start \\ "00:00:00" , final \\ "00:01:00" )
  defp create_from_format(stuff, format, start , final) when format == :gif do
      stuff 
      |> add_output_file(File.cwd! <> "/output/output.gif")
      |> add_file_option(option_ss(start))
      |> add_file_option(option_t(final))
  end

  defp create_from_format(stuff, format, start, final) when format == :webm do
      stuff
      |> add_output_file(File.cwd! <> "/output/output.webm")
      |> add_file_option(option_ss(start))
      |> add_file_option(option_t(final))
  end

end
