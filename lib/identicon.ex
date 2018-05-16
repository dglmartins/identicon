defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%{grid: grid} = data) do
    pixel_map =
      Enum.map grid, fn({_code, index}) ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}
        {top_left, bottom_right}
      end
    Map.put(data, :pixel_map, pixel_map)
  end

  def filter_odd_squares(%{grid: grid} = data) do
    grid =
      Enum.filter grid, fn({code, _index}) ->
        rem(code, 2) == 0
      end
    Map.put(data, :grid, grid)
  end

  def build_grid(%{hex: hex} = data) do
    grid =
      hex
      |> Stream.chunk(3)
      |> Stream.map(&mirror_row/1)
      |> Stream.flat_map(fn(x) -> x end)
      |> Enum.with_index
    Map.put(data, :grid, grid)
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  # here we have access to image, r, g, b. we pattern match right inside the argument list.
  def pick_color(%{hex: [r, g, b | _tail ]} = data) do
    Map.put(data, :color, {r, g, b})
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %{hex: hex}
  end
end
