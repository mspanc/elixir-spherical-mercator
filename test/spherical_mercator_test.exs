defmodule SphericalMercatorTest do
  use ExUnit.Case
  doctest SphericalMercator

  test "new/1 with no options given initializes the cache and returns the struct" do
    sm = SphericalMercator.new()

    # Values taken from the original JS project
    assert sm.cache.ac == [
      256,
      512,
      1024,
      2048,
      4096,
      8192,
      16384,
      32768,
      65536,
      131072,
      262144,
      524288,
      1048576,
      2097152,
      4194304,
      8388608,
      16777216,
      33554432,
      67108864,
      134217728,
      268435456,
      536870912,
      1073741824,
      2147483648,
      4294967296,
      8589934592,
      17179869184,
      34359738368,
      68719476736,
      137438953472
    ]

    assert sm.cache.bc == [
      0.7111111111111111,
      1.4222222222222223,
      2.8444444444444446,
      5.688888888888889,
      11.377777777777778,
      22.755555555555556,
      45.51111111111111,
      91.02222222222223,
      182.04444444444445,
      364.0888888888889,
      728.1777777777778,
      1456.3555555555556,
      2912.711111111111,
      5825.422222222222,
      11650.844444444445,
      23301.68888888889,
      46603.37777777778,
      93206.75555555556,
      186413.51111111112,
      372827.02222222224,
      745654.0444444445,
      1491308.088888889,
      2982616.177777778,
      5965232.355555556,
      11930464.711111112,
      23860929.422222223,
      47721858.844444446,
      95443717.68888889,
      190887435.37777779,
      381774870.75555557
    ]

    assert sm.cache.cc == [
      40.74366543152521,
      81.48733086305042,
      162.97466172610083,
      325.94932345220167,
      651.8986469044033,
      1303.7972938088067,
      2607.5945876176133,
      5215.189175235227,
      10430.378350470453,
      20860.756700940907,
      41721.51340188181,
      83443.02680376363,
      166886.05360752725,
      333772.1072150545,
      667544.214430109,
      1335088.428860218,
      2670176.857720436,
      5340353.715440872,
      10680707.430881744,
      21361414.86176349,
      42722829.72352698,
      85445659.44705395,
      170891318.8941079,
      341782637.7882158,
      683565275.5764316,
      1367130551.1528633,
      2734261102.3057265,
      5468522204.611453,
      10937044409.222906,
      21874088818.445812
    ]

    assert sm.cache.zc == [
      128,
      256,
      512,
      1024,
      2048,
      4096,
      8192,
      16384,
      32768,
      65536,
      131072,
      262144,
      524288,
      1048576,
      2097152,
      4194304,
      8388608,
      16777216,
      33554432,
      67108864,
      134217728,
      268435456,
      536870912,
      1073741824,
      2147483648,
      4294967296,
      8589934592,
      17179869184,
      34359738368,
      68719476736
    ]

    assert sm.size == 256
    assert sm.expansion == 1
  end

  test "new/1 with size set to 512 given initializes the cache and returns the struct" do
    sm = SphericalMercator.new([size: 512])

    # Values taken from the original JS project
    assert sm.cache.ac == [
      512,
      1024,
      2048,
      4096,
      8192,
      16384,
      32768,
      65536,
      131072,
      262144,
      524288,
      1048576,
      2097152,
      4194304,
      8388608,
      16777216,
      33554432,
      67108864,
      134217728,
      268435456,
      536870912,
      1073741824,
      2147483648,
      4294967296,
      8589934592,
      17179869184,
      34359738368,
      68719476736,
      137438953472,
      274877906944
    ]

    assert sm.cache.bc == [
      1.4222222222222223,
      2.8444444444444446,
      5.688888888888889,
      11.377777777777778,
      22.755555555555556,
      45.51111111111111,
      91.02222222222223,
      182.04444444444445,
      364.0888888888889,
      728.1777777777778,
      1456.3555555555556,
      2912.711111111111,
      5825.422222222222,
      11650.844444444445,
      23301.68888888889,
      46603.37777777778,
      93206.75555555556,
      186413.51111111112,
      372827.02222222224,
      745654.0444444445,
      1491308.088888889,
      2982616.177777778,
      5965232.355555556,
      11930464.711111112,
      23860929.422222223,
      47721858.844444446,
      95443717.68888889,
      190887435.37777779,
      381774870.75555557,
      763549741.5111111
    ]

    assert sm.cache.cc == [
      81.48733086305042,
      162.97466172610083,
      325.94932345220167,
      651.8986469044033,
      1303.7972938088067,
      2607.5945876176133,
      5215.189175235227,
      10430.378350470453,
      20860.756700940907,
      41721.51340188181,
      83443.02680376363,
      166886.05360752725,
      333772.1072150545,
      667544.214430109,
      1335088.428860218,
      2670176.857720436,
      5340353.715440872,
      10680707.430881744,
      21361414.86176349,
      42722829.72352698,
      85445659.44705395,
      170891318.8941079,
      341782637.7882158,
      683565275.5764316,
      1367130551.1528633,
      2734261102.3057265,
      5468522204.611453,
      10937044409.222906,
      21874088818.445812,
      43748177636.891624
    ]

    assert sm.cache.zc == [
      256,
      512,
      1024,
      2048,
      4096,
      8192,
      16384,
      32768,
      65536,
      131072,
      262144,
      524288,
      1048576,
      2097152,
      4194304,
      8388608,
      16777216,
      33554432,
      67108864,
      134217728,
      268435456,
      536870912,
      1073741824,
      2147483648,
      4294967296,
      8589934592,
      17179869184,
      34359738368,
      68719476736,
      137438953472
    ]

    assert sm.size == 512
    assert sm.expansion == 1
  end

  test "px/3 for size 256 and integer zoom returns pixel coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.px([19.940695, 50.048969], 15)

    assert result == [
      4658956,
      2843176
    ]
  end

  test "px/3 for size 512 and integer zoom returns pixel coordinates" do
    result =
      SphericalMercator.new([size: 512])
      |> SphericalMercator.px([19.940695, 50.048969], 15)

    assert result == [
      9317912,
      5686353
    ]
  end

  test "px/3 for size 512 and floating-point zoom returns pixel coordinates" do
    result =
      SphericalMercator.new([size: 512])
      |> SphericalMercator.px([19.940695, 50.048969], 15.4)

    assert result == [
      12295058.255764633,
      7503187.740029268
    ]
  end


  test "ll/3 for size 256 and integer zoom returns WGS84 coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.ll([4658956, 2843176], 15)

    assert result == [
      19.94070053100586,
      50.048982497585754
    ]
  end

  test "ll/3 for size 512 and integer zoom returns WGS84 coordinates" do
    result =
      SphericalMercator.new([size: 512])
      |> SphericalMercator.ll([9317912, 5686353], 15)

    assert result == [
      19.94070053100586,
      50.04896871891559 # browser retuns 7 as last digit but nevermind
    ]
  end

  test "ll/3 for size 512 and floating-point zoom returns WGS84 coordinates" do
    result =
      SphericalMercator.new([size: 512])
      |> SphericalMercator.ll([12295058, 7503187], 15.4)

    assert result == [
      19.94069084078761,
      50.04897672759276
    ]
  end

  test "bbox/3 for size 512 returns and integer zoom returns bounding box" do
   result =
     SphericalMercator.new([size: 512])
     |> SphericalMercator.bbox(36396, 22212, 16)

    assert result == [
      19.92919921875,
      50.04655739071663,
      19.9346923828125,
      50.05008477838258 # browser returns 6 as last digit but nevermind
    ]
  end

  test "forward/2 if given coordinates within extent returns coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.forward([19.940695, 50.048969])

    assert result == [
      2219788.013463977,
      6454760.73212724 # browser returns 38 instead of 4 at the end but nevermind
    ]
  end

  test "forward/2 if given coordinates outside extent (lat, positive) returns coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.forward([19.940695, 89.9])

    assert result == [
      2219788.013463977,
      20037508.342789244 # extent
    ]
  end

  test "forward/2 if given coordinates outside extent (lat, negative positive) returns coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.forward([19.940695, -89.9])

    assert result == [
      2219788.013463977,
      -20037508.342789244 # extent
    ]
  end

  test "forward/2 if given coordinates outside extent (lng, positive) returns coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.forward([180.1, 50.048969])

    assert result == [
      20037508.342789244, # extent
      6454760.73212724 # browser returns 38 instead of 4 at the end but nevermind
    ]
  end

  test "forward/2 if given coordinates outside extent (lng, negative positive) returns coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.forward([-180.1, 50.048969])

    assert result == [
      -20037508.342789244, # extent
      6454760.73212724 # browser returns 38 instead of 4 at the end but nevermind
    ]
  end

  test "inverse/2 if given coordinates within extent returns coordinates" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.inverse([2219788, 6454760])

    assert result == [
      19.940694879051044,
      50.048964776814756
    ]
  end

  test "xyz/5 if given coordinates returns xyz bounding box" do
    result =
      SphericalMercator.new([size: 512])
      |> SphericalMercator.xyz([
        19.932257,
        50.036332,
        19.940695,
        50.048969
      ], 16)

    assert result == [
      36396,
      22212,
      36398,
      22215,
    ]
  end

  test "convert/3 if given coordinates are in WGS84 and target is 900913 it returns bounding box" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.convert([
        19.932257,
        50.036332,
        19.940695,
        50.048969
      ], "900913")

    assert result == [
      2218848.6996006626,
      6452570.282497349,
      2219788.013463977,
      6454760.73212724 # browser returns 38 instead of 4 at the end but nevermind
    ]
  end

  test "convert/3 if given coordinates are in 900913 and target is WGS84 it returns bounding box" do
    result =
      SphericalMercator.new()
      |> SphericalMercator.convert([
        2218848.6,
        6452570.2,
        2219788.0,
        6454760.7
      ], "WGS84")

    assert result == [
      19.932256105272025,
      50.036331523998975,
      19.940694879051044,
      50.04896881467802
    ]
  end
end
