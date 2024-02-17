defmodule SphericalMercator do
  @moduledoc """
  This is a port of
  [MapBox's SphericalMercator JS library](http://github.com/mapbox/sphericalmercator)
  to Elixir.

  The API remains similar, so refer to the original project
  for the documentation.

  The code could be prettier but it aims at following the
  style of original implementation.
  """

  @d2r :math.pi() / 180
  @r2d 180 / :math.pi()
  @a 6378137.0
  @maxextent 20037508.342789244

  @type t() :: %__MODULE__{
    cache: Map.t(),
    size: number(),
    expansion: pos_integer(),
  }

  @typedoc """
  Two-element list with coordinates in the form `[x,y]` or `[long,lat]`.
  """
  @type coords() :: [float()]

  @typedoc """
  Projection, either "WGS84" or "900913".
  """
  @type srs() :: String.t()

  @typedoc """
  Four-element list with coords bounding box in the form `[w, s, e, n]`.
  """
  @type coordsbox() :: [float()]

  @typedoc """
  Four-element list with XYZ bounding box in the form `[min_x, min_y, max_x, max_y]`.
  """
  @type xyzbox() :: [pos_integer()]

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
  - `ll` - a list (`[lon, lat]`) of geographic coordinates.
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
  - `px` - a list (`[x, y]`) array of geographic coordinates.
  - `zoom` - zoom level.
  """
  @spec ll(t(), coords(), number()) :: coords()
  def ll(%__MODULE__{} = sm, px, zoom) do
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

  @doc """
  Convert tile xyz value to bbox of the form `[w, s, e, n]`

  - `sm` - a SphericalMercator struct
  - `x` - x (longitude) number
  - `y` - y (latitude) number
  - `zoom` - zoom
  - `tms_style` - whether to compute using tms-style
  - `srs` - projection for resulting bbox (WGS84|900913)

  Returns a bbox list of values in form `[w, s, e, n]`.
  """
  @spec bbox(t(), pos_integer(), pos_integer(), number(), boolean(), srs()) :: coordsbox()
  def bbox(%__MODULE__{} = sm, x, y, zoom, tms_style \\ false, srs \\ "WGS84") do
     y =
      if tms_style do
        (:math.pow(2, zoom) - 1) - y
      else
        y
      end

     ll = [x * sm.size, (y + 1) * sm.size]
     ur = [(x + 1) * sm.size, y * sm.size]

     bbox = ll(sm, ll, zoom) ++ ll(sm, ur, zoom)

     if srs == "900913" do
       convert(sm, bbox, "900913")
     else
       bbox
     end
  end

  @doc """
  Convert lon/lat values to 900913 x/y.
  """
  @spec forward(t(), coords()) :: coords()
  def forward(%__MODULE__{} = _sm, ll) do
    x = @a * hd(ll) * @d2r
    y = @a * :math.log(:math.tan((:math.pi * 0.25) + (0.5 * Enum.at(ll, 1) * @d2r)))

    x =
      cond do
        x > @maxextent ->
          @maxextent
        x < -@maxextent ->
          -@maxextent
        true ->
          x
      end

      y =
        cond do
          y > @maxextent ->
            @maxextent
          y < -@maxextent ->
            -@maxextent
          true ->
            y
        end

     [x,y]
  end

  @doc """
  Convert bbox to xyx bounds

  - `bbox` - bbox in the form `[w, s, e, n]`.
  - `zoom` - zoom.
  - `tms_style` - whether to compute using tms-style.
  - `srs` - projection of input bbox (WGS84|900913).

  Returns XYZ bounding box with list `[minX, maxX, minY, maxY]`.
  """
  @spec xyz(t(), coordsbox(), number(), boolean(), srs()) :: xyzbox()
  def xyz(%__MODULE__{} = sm, bbox, zoom, tms_style \\ false, srs \\ "WGS84") do
    bbox =
      if srs == "900913" do
        convert(sm, bbox, "WGS84")
      else
        bbox
      end

    [w, s, e, n] = bbox

    ll = [w, s]
    ur = [e, n]

    px_ll = px(sm, ll, zoom)
    px_ur = px(sm, ur, zoom)

    x = [ trunc(hd(px_ll) / sm.size), trunc((hd(px_ur) - 1) / sm.size) ]
    y = [ trunc(Enum.at(px_ur, 1) / sm.size), trunc((Enum.at(px_ll, 1) - 1) / sm.size) ]

    min_x =
      if apply(Kernel, :min, x) < 0 do
        0
      else
        apply(Kernel, :min, x)
      end

    min_y =
      if apply(Kernel, :min, y) < 0 do
        0
      else
        apply(Kernel, :min, y)
      end

    max_x =
      apply(Kernel, :max, x)
    max_y =
      apply(Kernel, :max, y)

    [min_x, max_y] =
      if tms_style do
        min_y = (:math.pow(2, zoom) - 1) - max_y
        max_y = (:math.pow(2, zoom) - 1) - min_y
        [min_x, max_y]
      else
        [min_x, max_y]
      end

    [min_x, min_y, max_x, max_y]
  end

  @doc """
  Convert projection of given bbox.

  - `bbox` - bbox in the form `[w, s, e, n]`.
  - `to` - projection of output bbox (WGS84|900913). Input bbox
         assumed to be the "other" projection.

  Returns bbox with reprojected coordinates.
  """
  @spec convert(t(), coordsbox(), srs()) :: coordsbox()
  def convert(%SphericalMercator{} = sm, [w, s, e, n], "900913") do
    forward(sm, [w, s]) ++ forward(sm, [e, n])
  end

  def convert(%SphericalMercator{} = sm, [w, s, e, n], "WGS84") do
    inverse(sm, [w, s]) ++ inverse(sm, [e, n])
  end

  @doc """
  Convert 900913 x/y values to lon/lat.
  """
  @spec inverse(t(), coords()) :: coords()
  def inverse(%__MODULE__{} = _sm, xy) do
    [
      hd(xy) * @r2d / @a,
      ((:math.pi * 0.5) - 2.0 * :math.atan(:math.exp(-Enum.at(xy, 1) / @a))) * @r2d
    ]
  end
end
