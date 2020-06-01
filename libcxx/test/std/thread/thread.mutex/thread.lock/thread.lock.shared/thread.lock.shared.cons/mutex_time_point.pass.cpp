//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// UNSUPPORTED: libcpp-has-no-threads
// UNSUPPORTED: c++03, c++11
// XFAIL: dylib-has-no-shared_mutex

// ALLOW_RETRIES: 2

// <shared_mutex>

// class shared_timed_mutex;

// template <class Clock, class Duration>
//   shared_lock(mutex_type& m, const chrono::time_point<Clock, Duration>& abs_time);

#include <shared_mutex>
#include <thread>
#include <vector>
#include <cstdlib>
#include <cassert>

#include "test_macros.h"

std::shared_timed_mutex m;

typedef std::chrono::steady_clock Clock;
typedef Clock::time_point time_point;
typedef Clock::duration duration;
typedef std::chrono::milliseconds ms;
typedef std::chrono::nanoseconds ns;

// Thread sanitizer causes more overhead and will sometimes cause this test
// to fail. To prevent this we give Thread sanitizer more time to complete the
// test.
#if !defined(TEST_HAS_SANITIZERS) && !TEST_SLOW_HOST()
#define LONGDELAY() 0
#else
#define LONGDELAY() 1
#endif

static ms Tolerance = ms(LONGDELAY() ? 150 : 50); // 150ms for slow hosts, 50ms otherwise
static ms WaitTime = ms(LONGDELAY() ? 800 : 250);

void f1()
{
    time_point t0 = Clock::now();
    std::shared_lock<std::shared_timed_mutex> lk(m, Clock::now() + WaitTime + Tolerance);
    assert(lk.owns_lock() == true);
    time_point t1 = Clock::now();
    ns d = t1 - t0 - WaitTime;
    assert(d < Tolerance);  // within 50ms
}

void f2()
{
    time_point t0 = Clock::now();
    std::shared_lock<std::shared_timed_mutex> lk(m, Clock::now() + WaitTime);
    assert(lk.owns_lock() == false);
    time_point t1 = Clock::now();
    ns d = t1 - t0 - WaitTime;
    assert(d < Tolerance);  // within 50ms
}

int main(int, char**)
{
    {
        m.lock();
        std::vector<std::thread> v;
        for (int i = 0; i < (TEST_SLOW_HOST() ? 2 : 5); ++i)
            v.push_back(std::thread(f1));
        std::this_thread::sleep_for(WaitTime);
        m.unlock();
        for (auto& t : v)
            t.join();
    }
    {
        m.lock();
        std::vector<std::thread> v;
        for (int i = 0; i < (TEST_SLOW_HOST() ? 2 : 5); ++i)
            v.push_back(std::thread(f2));
        std::this_thread::sleep_for(WaitTime + Tolerance);
        m.unlock();
        for (auto& t : v)
            t.join();
    }

  return 0;
}
