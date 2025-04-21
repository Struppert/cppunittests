
#define CATCH_CONFIG_MAIN
#include <catch2/catch_all.hpp>

TEST_CASE("Simple test", "[basic]") { REQUIRE(1 + 1 == 2); }
