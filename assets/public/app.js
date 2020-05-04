(function() {
  'use strict';

  var globals = typeof global === 'undefined' ? self : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = {}.hasOwnProperty;

  var expRe = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (expRe.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var hot = hmr && hmr.createHot(name);
    var module = {id: name, exports: {}, hot: hot};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var expandAlias = function(name) {
    var val = aliases[name];
    return (val && name !== val) ? expandAlias(val) : name;
  };

  var _resolve = function(name, dep) {
    return expandAlias(expand(dirname(name), dep));
  };

  var require = function(name, loaderPath) {
    if (loaderPath == null) loaderPath = '/';
    var path = expandAlias(name);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    throw new Error("Cannot find module '" + name + "' from '" + loaderPath + "'");
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  var extRe = /\.[^.\/]+$/;
  var indexRe = /\/index(\.[^\/]+)?$/;
  var addExtensions = function(bundle) {
    if (extRe.test(bundle)) {
      var alias = bundle.replace(extRe, '');
      if (!has.call(aliases, alias) || aliases[alias].replace(extRe, '') === alias + '/index') {
        aliases[alias] = bundle;
      }
    }

    if (indexRe.test(bundle)) {
      var iAlias = bundle.replace(indexRe, '');
      if (!has.call(aliases, iAlias)) {
        aliases[iAlias] = bundle;
      }
    }
  };

  require.register = require.define = function(bundle, fn) {
    if (bundle && typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          require.register(key, bundle[key]);
        }
      }
    } else {
      modules[bundle] = fn;
      delete cache[bundle];
      addExtensions(bundle);
    }
  };

  require.list = function() {
    var list = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        list.push(item);
      }
    }
    return list;
  };

  var hmr = globals._hmr && new globals._hmr(_resolve, require, modules, cache);
  require._cache = cache;
  require.hmr = hmr && hmr.wrap;
  require.brunch = true;
  globals.require = require;
})();

(function() {
var global = typeof window === 'undefined' ? this : window;
var __makeRelativeRequire = function(require, mappings, pref) {
  var none = {};
  var tryReq = function(name, pref) {
    var val;
    try {
      val = require(pref + '/node_modules/' + name);
      return val;
    } catch (e) {
      if (e.toString().indexOf('Cannot find module') === -1) {
        throw e;
      }

      if (pref.indexOf('node_modules') !== -1) {
        var s = pref.split('/');
        var i = s.lastIndexOf('node_modules');
        var newPref = s.slice(0, i).join('/');
        return tryReq(name, newPref);
      }
    }
    return none;
  };
  return function(name) {
    if (name in mappings) name = mappings[name];
    if (!name) return;
    if (name[0] !== '.' && pref) {
      var val = tryReq(name, pref);
      if (val !== none) return val;
    }
    return require(name);
  }
};
require.register("test/metrics_live_test.js", function(exports, require, module) {
// Initialize the uPlot mocks
const mockDelSeries = jest.fn()
const mockAddSeries = jest.fn()
const mockSetData = jest.fn()

jest.mock('uplot', () => {
  return {
    __esModule: true,
    default: jest.fn(() => {
      return {
        series: [],
        addSeries: mockAddSeries,
        delSeries: mockDelSeries,
        setData: mockSetData
      }
    })
  }
})

import { TelemetryChart, newSeriesConfig } from '../js/metrics_live'
import uPlot from 'uplot'

beforeEach(() => {
  // Clear all instances and calls to constructor and all methods:
  uPlot.mockClear()
  mockDelSeries.mockClear()
  mockSetData.mockClear()
})

describe('TelemetryChart', () => {
  test('instantiates uPlot', () => {
    const chart = new TelemetryChart(document.body, { metric: 'counter', tagged: false })

    expect(uPlot).toHaveBeenCalledTimes(1)
  })

  test('raises without metric', () => {
    expect(() => {
      new TelemetryChart(document.body, {})
    }).toThrowError(new TypeError(`No metric type was provided`))
  })

  test('raises if metric is invalid', () => {
    expect(() => {
      new TelemetryChart(document.body, { metric: 'invalid' })
    }).toThrowError(new TypeError(`No metric defined for type invalid`))
  })
})

describe('Metrics no tags', () => {
  test('Counter', () => {
    const chart = new TelemetryChart(document.body, { metric: 'counter', tagged: false })

    chart.pushData([{ x: 'a', y: 2, z: 1 }])

    expect(mockSetData).toHaveBeenCalledWith([
      [1],
      [1]
    ])

    chart.pushData([{ x: 'b', y: 4, z: 3 }])

    expect(mockSetData).toHaveBeenCalledWith([
      [1, 3],
      [1, 2]
    ])

    chart.pushData([
      { x: 'c', y: 6, z: 5 },
      { x: 'd', y: 8, z: 7 }
    ])

    expect(mockSetData).toHaveBeenCalledWith([
      [1, 3, 5, 7],
      [1, 2, 3, 4]
    ])
  })

  test('LastValue', () => {
    const chart = new TelemetryChart(document.body, { metric: 'last_value', tagged: false })

    chart.pushData([{ x: 'a', y: 2, z: 1 }])

    expect(mockSetData).toHaveBeenCalledWith([
      [1],
      [2]
    ])

    chart.pushData([{ x: 'b', y: 4, z: 3 }])

    expect(mockSetData).toHaveBeenCalledWith([
      [1, 3],
      [2, 4]
    ])

    chart.pushData([
      { x: 'c', y: 6, z: 5 },
      { x: 'd', y: 8, z: 7 }
    ])

    expect(mockSetData).toHaveBeenCalledWith([
      [1, 3, 5, 7],
      [2, 4, 6, 8]
    ])
  })

  test('Sum', () => {
    const chart = new TelemetryChart(document.body, { metric: 'sum', tagged: false })

    chart.pushData([{ x: 'a', y: 2, z: 1 }])

    expect(mockSetData).toHaveBeenCalledWith([
      [1],
      [2]
    ])

    chart.pushData([{ x: 'b', y: 4, z: 3 }])

    expect(mockSetData).toHaveBeenCalledWith([
      [1, 3],
      [2, 6]
    ])

    chart.pushData([
      { x: 'c', y: 6, z: 5 },
      { x: 'd', y: 8, z: 7 }
    ])

    expect(mockSetData).toHaveBeenCalledWith([
      [1, 3, 5, 7],
      [2, 6, 12, 20]
    ])
  })

  describe('Summary', () => {
    test('initializes the chart', () => {
      const chart = new TelemetryChart(document.body, { metric: 'summary', tagged: true })
      expect(mockDelSeries).toHaveBeenCalledTimes(0)
    })

    test('pushes value/min/max/avg', () => {
      const chart = new TelemetryChart(document.body, { metric: 'summary', tagged: true })
      chart.pushData([{ x: 'a', y: 2, z: 1 }])

      expect(mockSetData).toHaveBeenCalledWith([
        [1],
        [2],
        [2],
        [2],
        [2]
      ])

      chart.pushData([{ x: 'b', y: 4, z: 3 }])

      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3],
        [2, 4],
        [2, 2],
        [2, 4],
        [2, 3]
      ])

      chart.pushData([
        { x: 'c', y: 6, z: 5 },
        { x: 'd', y: 8, z: 7 }
      ])

      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3, 5, 7],
        [2, 4, 6, 8],
        [2, 2, 2, 2],
        [2, 4, 6, 8],
        [2, 3, 4, 5]
      ])
    })
  })
})

describe('Metrics with tags', () => {
  describe('LastValue', () => {
    test('deletes initial dataset', () => {
      const chart = new TelemetryChart(document.body, { metric: 'last_value', tagged: true })
      expect(mockDelSeries).toHaveBeenCalledWith(1)
    })

    test('aligns data by tag', () => {
      const chart = new TelemetryChart(document.body, { metric: 'last_value', tagged: true })

      chart.pushData([{ x: 'a', y: 2, z: 1 }])
      expect(mockAddSeries).toHaveBeenCalledWith(newSeriesConfig({ label: 'a' }, 0), 1)
      expect(mockSetData).toHaveBeenCalledWith([
        [1],
        [2]
      ])

      chart.pushData([{ x: 'b', y: 4, z: 3 }])
      expect(mockAddSeries).toHaveBeenCalledWith(newSeriesConfig({ label: 'b' }, 1), 2)
      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3],
        [2, null],
        [null, 4]
      ])

      chart.pushData([
        { x: 'b', y: 6, z: 5 },
        { x: 'a', y: 8, z: 7 }
      ])

      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3, 5, 7],
        [2, null, null, 8],
        [null, 4, 6, null]
      ])
    })
  })

  describe('Counter', () => {
    test('deletes initial dataset', () => {
      const chart = new TelemetryChart(document.body, { metric: 'counter', tagged: true })
      expect(mockDelSeries).toHaveBeenCalledWith(1)
    })

    test('aligns data by tag', () => {
      const chart = new TelemetryChart(document.body, { metric: 'counter', tagged: true })

      chart.pushData([{ x: 'a', y: 2, z: 1 }])
      expect(mockAddSeries).toHaveBeenCalledWith(newSeriesConfig({ label: 'a' }, 0), 1)
      expect(mockSetData).toHaveBeenCalledWith([
        [1],
        [1]
      ])

      chart.pushData([{ x: 'b', y: 4, z: 3 }])
      expect(mockAddSeries).toHaveBeenCalledWith(newSeriesConfig({ label: 'b' }, 1), 2)
      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3],
        [1, null],
        [null, 1]
      ])

      chart.pushData([
        { x: 'b', y: 6, z: 5 },
        { x: 'a', y: 8, z: 7 }
      ])

      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3, 5, 7],
        [1, null, null, 2],
        [null, 1, 2, null]
      ])
    })
  })

  describe('Sum', () => {
    test('deletes initial dataset', () => {
      const chart = new TelemetryChart(document.body, { metric: 'sum', tagged: true })
      expect(mockDelSeries).toHaveBeenCalledWith(1)
    })

    test('aligns data by tag', () => {
      const chart = new TelemetryChart(document.body, { metric: 'sum', tagged: true })

      chart.pushData([{ x: 'a', y: 2, z: 1 }])
      expect(mockAddSeries).toHaveBeenCalledWith(newSeriesConfig({ label: 'a' }, 0), 1)
      expect(mockSetData).toHaveBeenCalledWith([
        [1],
        [2]
      ])

      chart.pushData([{ x: 'b', y: 4, z: 3 }])
      expect(mockAddSeries).toHaveBeenCalledWith(newSeriesConfig({ label: 'b' }, 1), 2)
      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3],
        [2, null],
        [null, 4]
      ])

      chart.pushData([
        { x: 'b', y: 6, z: 5 },
        { x: 'a', y: 8, z: 7 }
      ])

      expect(mockSetData).toHaveBeenCalledWith([
        [1, 3, 5, 7],
        [2, null, null, 10],
        [null, 4, 10, null]
      ])
    })
  })
})

});

;require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');


//# sourceMappingURL=app.js.map