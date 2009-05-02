require 'ramaze'

class BenchCore < Ramaze::Controller
  map '/'
end

Ramaze.start(:started => true)

Innate::Log.loggers.clear

require 'benchmark'

Benchmark.bmbm(20) do |b|
  n = 500
  urls = ['/small', '/large']
  engines = %w[Etanni Haml ERB]

  urls.each do |url|
    engines.each do |engine|
      b.report("Unached %10s %p:" % [engine, url]) do
        BenchCore.provide(:html, :engine => engine)
        Innate::View.options.cache = false
        n.times{ Innate::Mock.get(url) }
      end

      b.report("Cached %11s %p:" % [engine, url]) do
        BenchCore.provide(:html, :engine => engine)
        Innate::Cache.view.clear
        Innate::View.options.cache = true
        n.times{ Innate::Mock.get(url) }
      end
    end
  end
end

__END__
This benchmark is from Sat May  2 14:58:14 JST 2009
n = 500

Rehearsal ----------------------------------------------------------------
Unached     Etanni "/small":   6.560000   0.490000   7.050000 (  7.138829)
Cached      Etanni "/small":   6.370000   0.420000   6.790000 (  6.859946)
Unached       Haml "/small":   8.680000   0.600000   9.280000 (  9.379500)
Cached        Haml "/small":   6.830000   0.370000   7.200000 (  7.239311)
Unached        ERB "/small":   8.980000   0.540000   9.520000 (  9.585725)
Cached         ERB "/small":   6.470000   0.450000   6.920000 (  6.961339)
Unached     Etanni "/large":   7.800000   0.490000   8.290000 (  8.338521)
Cached      Etanni "/large":   7.480000   0.400000   7.880000 (  7.927069)
Unached       Haml "/large":  11.970000   0.620000  12.590000 ( 12.645620)
Cached        Haml "/large":   6.760000   0.490000   7.250000 (  7.296633)
Unached        ERB "/large":  20.700000   1.000000  21.700000 ( 21.752810)
Cached         ERB "/large":   7.590000   0.430000   8.020000 (  8.079993)
----------------------------------------------------- total: 112.490000sec

                                   user     system      total        real
Unached     Etanni "/small":   6.450000   0.420000   6.870000 (  6.869656)
Cached      Etanni "/small":   6.280000   0.420000   6.700000 (  6.702520)
Unached       Haml "/small":   8.810000   0.510000   9.320000 (  9.343563)
Cached        Haml "/small":   6.670000   0.450000   7.120000 (  7.125798)
Unached        ERB "/small":   8.890000   0.540000   9.430000 (  9.450362)
Cached         ERB "/small":   6.530000   0.400000   6.930000 (  6.942688)
Unached     Etanni "/large":   7.830000   0.500000   8.330000 (  8.348678)
Cached      Etanni "/large":   7.320000   0.470000   7.790000 (  7.798482)
Unached       Haml "/large":  11.880000   0.630000  12.510000 ( 12.531796)
Cached        Haml "/large":   6.870000   0.410000   7.280000 (  7.298600)
Unached        ERB "/large":  20.570000   0.930000  21.500000 ( 21.523399)
Cached         ERB "/large":   7.560000   0.430000   7.990000 (  7.999896)
