defmodule SphericalMercator do
  @epsln 1.0e-10
  @d2r :math.pi() / 180
  @r2d 180 / :math.pi()
  @a 6378137.0
  @maxextent 20037508.342789244

  @type t() :: %__MODULE__{
    cache: Map.t(),
    size: number(),
    expansion: pos_integer(),
  }

  @type coords() :: [float()]

  defp has_rem(n), do: trunc(n) != n

  defstruct cache: nil, size: nil, expansion: nil

  @doc """
  SphericalMercator constructor: precaches calculations
  for fast tile lookups.
  """
  @spec new(Keyword.t()) :: t()
  def new(options \\ []) do
    size = options[:size] || 256
    expansion = if options[:antimeridian], do: 2, else: 1

    {bc, cc, zc, ac} = do_new(0, [], [], [], [], size)
    cache = %{
      bc: bc,
      cc: cc,
      zc: zc,
      ac: ac,
    }

    %__MODULE__{
      cache: cache,
      expansion: expansion,
      size: size
    }
  end

  defp do_new(30, bc, cc, zc, ac, _size) do
    {
      bc |> Enum.reverse(),
      cc |> Enum.reverse(),
      zc |> Enum.reverse(),
      ac |> Enum.reverse()
    }
  end

  defp do_new(n, bc, cc, zc, ac, size) do
    do_new(n + 1,
      [size / 360 | bc],
      [size / (2 * :math.pi) | cc],
      [size / 2 | zc],
      [size | ac],
      size * 2
    )
  end


  @doc """
  Convert lon lat to screen pixel value.

  - `sm` - a SphericalMercator struct
  - `ll` - list (`[lon, lat]`) of geographic coordinates.
  - `zoom` - zoom level.
  """
  @spec px(t(), coords(), number()) :: coords()
  def px(%__MODULE__{} = sm, ll, zoom) do
    if has_rem(zoom) do
      size = sm.size * :math.pow(2, zoom)
      d = size / 2
      bc = size / 360
      cc = size / (2 * :math.pi)
      ac = size
      f = min(max(:math.sin(@d2r * Enum.at(ll, 1)), -0.9999), 0.9999)
      x = d + hd(ll) * bc
      y = d + 0.5 * :math.log((1 + f) / (1 - f)) * -cc
      x =
        if x > ac * sm.expansion do
          ac * sm.expansion
        else
          x
        end

      y =
        if y > ac do
          ac
        else
          y
        end

      [x, y]
    else
      d = Enum.at(sm.cache[:zc], zoom)
      f = min(max(:math.sin(@d2r * Enum.at(ll, 1)), -0.9999), 0.9999)
      x = round(d + hd(ll) * Enum.at(sm.cache[:bc], zoom))
      y = round(d + 0.5 * :math.log((1 + f) / (1 - f)) * (-Enum.at(sm.cache[:cc], zoom)))
      x =
        if x > Enum.at(sm.cache[:ac], zoom) * sm.expansion do
          Enum.at(sm.cache[:ac], zoom) * sm.expansion
        else
          x
        end

      y =
        if y > Enum.at(sm.cache[:ac], zoom) do
          Enum.at(sm.cache[:ac], zoom)
        else
          y
        end

      [x, y]
    end
  end

  @doc """
  Convert screen pixel value to lon lat

  - `sm` - a SphericalMercator struct
  - `px` {Array} `[x, y]` array of geographic coordinates.
  - `zoom` {Number} zoom level.
  """
  @spec ll(t(), coords(), number()) :: coords()
  def ll(%SphericalMercator{} = sm, px, zoom) do
    if has_rem(zoom) do
      size = sm.size * :math.pow(2, zoom)
      bc = size / 360
      cc = size / (2 * :math.pi)
      zc = size / 2
      g = (Enum.at(px, 1) - zc) / -cc
      lon = (hd(px) - zc) / bc
      lat = @r2d * (2 * :math.atan(:math.exp(g)) - 0.5 * :math.pi)
      [lon, lat]
    else
      g = (Enum.at(px, 1) - Enum.at(sm.cache.zc, zoom)) / (-Enum.at(sm.cache.cc, zoom))
      lon = (hd(px) - Enum.at(sm.cache.zc, zoom)) / Enum.at(sm.cache.bc, zoom)
      lat = @r2d * (2 * :math.atan(:math.exp(g)) - 0.5 * :math.pi)
      [lon, lat]
    end
  end
end
