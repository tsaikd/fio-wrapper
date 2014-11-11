# fio-wrapper

Generate fio job files and run them automatically.

## Quick Start

Run a fio test with all default parameters:

```bash
fio-wrapper 
```

## Run a more customized test

Test only 4k-size random read on a 4G file under `/mnt/fiotest`, with 1, 8
 and 64 threads. Save the output files to `~/fio-outputs/randread4k`:

```bash
RANDREAD_SIZES=4 MULTI_USERS=1,8,64 \
fio-wrapper -p /mnt/fiotest -o ~/fio-outputs/randread4k -t randread -m 4096
```

will get outputs like:

```
Configuration:
  IOPATH       = '/mnt/fiotest/fio_data'
  OUTPUT_DIR   = '/root/fio-outputs/randread4k'
  TESTS        = 'randread'
  TEST_SECOND  = '15'         TEST_FILE_MB = '4096'
  DIRECT       = '1'          KEEP_JOB = '0'

Wed Oct  1 22:04:53 CST 2014: Run fio randread 4k block 1 users
Wed Oct  1 22:05:02 CST 2014: Run fio randread 4k block 8 users
Wed Oct  1 22:05:13 CST 2014: Run fio randread 4k block 64 users

    test users size     MB      lat      min      max      std        IO/s  50us   1ms   4ms  10ms  20ms  50ms   .1s    1s    2s   2s+
randread     1   4K r   28.734    0.133    0.051    2.555    0.014    7356         100     0                                          
randread     8   4K r  188.817    0.163    0.037   44.086    0.115   48337     0    99     0           0     0                        
randread    64   4K r  286.435    0.870    0.042 2838.800   20.163   73327     0    97     2     0     0     0     0     0     0     0
```

## Configuration via Environment Variables

* `MULTI_USERS` is default to `1,8,16,32,64`
* `RANDREAD_SIZES` is default to `4,8`
* `READ_SIZES` is default to `4,8,32,128,1024`
* `WRITE_SIZES` is default to `4,8,32,128,1024`
* `RANDRW_SIZES` is default to `4,8`
* `FIO_PARSE_OPT` is default to `"-v"`

## Credits

The `fioparse.pl` and `fioparse.sh` are forks from 
[fio_scripts](https://github.com/khailey/fio_scripts).
