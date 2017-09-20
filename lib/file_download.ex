defmodule FileDownload do
import FFmpex
use FFmpex.Options

  @defaults %{quality: "22", start: "00:00:00", final: nil}

  @doc """
    allows you to download video. 
    link- youtube link 
    format - return format (webm, mp3, gif) - optional (default is webm)
    quality- which video quality to download - optional
    start - video start (default- 00:00:00) - optional
    final - video end (default 00:00:00)  - optional
  """
  def download(link, format \\ :webm, options \\ []) do
      %{quality: quality, start: start, final: final} = Enum.into(options, @defaults)

      {_, 0} = System.cmd("youtube-dl", [link, "-odownloaded/example.%(ext)s", "-q", "-f " <> quality])
      location = File.cwd! <> "/downloaded"
      {:ok, file_names} = location |> File.ls
      file_location = location <> "/" <> hd(file_names)
      convert_video file_location, start, final, format
      File.rm!(file_location)

      IO.puts Atom.to_string(format) <>" created successfully"
  end

  @doc """
    Gets youtube video possible qualities.
  """
  def get_quality(link) do
    {formats, 0} = System.cmd("youtube-dl", [link, "-F"])
    formats
      |> String.split("\n")
      |> Enum.reject(fn(x) -> !Regex.match?(~r/^[0-9]/, x) end )
      |> Enum.join("\n")
      |> IO.puts
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

  @doc """
    Creates specific format file from given video
  """
  defp create_from_format(command, format, start , final) when format == :gif do
      command 
      |> add_output_file(File.cwd! <> "/output/output.gif")
      |> add_file_option(option_ss(start))
      |> add_final_if_not_empty(final)
  end

  defp create_from_format(command, format, start, final) when format == :webm do
      command
      |> add_output_file(File.cwd! <> "/output/output.webm")
      |> add_file_option(option_ss(start))
      |> add_final_if_not_empty(final)
  end

  defp create_from_format(command, format, start, final) when format == :mp3 do
      command
      |> add_output_file(File.cwd! <> "/output/output.mp3")
      |> add_file_option(option_ss(start))
      |> add_final_if_not_empty(final)
      |> add_file_option(option_vn())
  end

  defp add_final_if_not_empty(command, nil), do: command
  defp add_final_if_not_empty(command, final) do
      command |> add_file_option(option_t(final))
  end

end
