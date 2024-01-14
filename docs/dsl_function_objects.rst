:blogpost: true
:date: 2024-01-14
:tags: blog, c++, c++20, DSL, metaprogramming
:author: Miro Palmu

DSL function objects (c++)
--------------------------

In this blog I'm going to describe metaprogramming technique that came up when
I was working on my WIP library. I have not seen it before so I coined term
DSL (Domain Spesific Language) function object.

DSL function object is function object which is created using some sort of DSL.
UDLs (User-Defined Literal) can return DSL function object which has variadic tempalted arguments which are
constrainted using a concept which models which combination of arguments is accepted
based on the DSL in the UDL string.

Due to usage of template constraints DSL function objects require c++20. I have a feeling that
all this could be emulated using some dark sorcery of earlier standards but I have not thought
of it enough.

For a example we define simple language which just controls which argument types are
accepted. Rules for this langauge:
    - only allowed characters 'A', 'B' and 'C'.
    - parameter to the DSL function object can only be of type A, B or C (defined in code)
    - parameters have to be given in order defined by the given characters

Then the DSL function object will print values inside these parameters
with name provided by ``std::type_info::name()``.
UDL for this DSL function object is ``""_p``. Exapmle usage ``"ABBCCC"_p(A{1}, B{2}, B{3}, C{4}, C{5}, C{6});``
which would give following output on gcc 10.1 (interestingly gcc adds '1' to the names):

.. code-block:: console

    1A is 0
    1B is 2
    1B is 3
    1C is 4
    1C is 5
    1C is 6

One could imagine doing anything you can with these arguments and the logic why some combination
of argument could be as complex as one wants.

Below is the code implementing DSL function object described above. It compiles with gcc 10.1
and clang 12.0.0 or newer (except clang 12.0.1) in c++20 mode. For some reason msvc does
not compile on any version. Here is the implementation in `godbold`_.

.. link to godbold
.. _`godbold`: https://godbolt.org/#z:OYLghAFBqd5QCxAYwPYBMCmBRdBLAF1QCcAaPECAMzwBtMA7AQwFtMQByARg9KtQYEAysib0QXACx8BBAKoBnTAAUAHpwAMvAFYTStJg1DIApACYAQuYukl9ZATwDKjdAGFUtAK4sGe1wAyeAyYAHI%2BAEaYxBIAzFykAA6oCoRODB7evnrJqY4CQSHhLFExXPG2mPb5DEIETMQEmT5%2BCXaYDul1DQSFYZHRegr1jc3ZbSO9wf0lg1wAlLaoXsTI7BzmscHI3lgA1CaxbmgMa4kECofYJhoAgpvbu5gHRwQAnomYAPoExEyEl1i1zuD1OTxebi8jlohDeVxu9zMWzBXn2hzcBC8iXo8JBSMeqOe6Pen2C/FxiORO0JEIafzhQIRoOpaKOfyMmEBwMpBNZbicw2ImFYFOZ4PRguCwFF%2BJRfOGWFUZwIMqp4qOYmAJEICBYqt5RKOkqMXwAbnhMAB3UV3AD0tr2ABEhAE9lQvKcantUBFtB0CHs8Ao3R7OgJvb7/XtLQg8MgEIHg8ghUwCJh0HsvKkjHsFKg2LmSAHUFQnS6AHQI%2B17OSOgJJwx7IWY4gMMuu92e9IRv0OaOx%2BN7BBMYOmhp4Jj4ZB7NMsRJiNMZhrAHyMC79uMJhqYKsOk6C/6CdOZ7PAPZMPYnZUbwcsDBVYMxzeX/MRYKp7sl8/EFdsQTBoNz2QZV013PYIhHY9wwIBBnmdV1ghnWCazrXNfilSs7VtMCADESHPPZMFUVhsTgl1o2eLAaBCXM8Dneg9gMIwvCYYBnifQdtCzAMTl%2BTxHwHLcf1XQQZw%2BTlvx3LCgJA9Byz2AAlLx6GDfhiCQwCmOAJgvDYkAwL2Qy9gAWm9BhaDec9aFoVBLWPeMGiYBxomDbc9jADhbg80h3I4CwPPPBgMw8twPMw25qyMky9nnP42DTdSSQkogkLIjtQy9H1ex4xsBAs8Dni/W4fIsb11LcPYICiGzLXmAyjNM2LWEwBLg2HU1nhSqI9mAPAOrbRCSCwdSqOmDMIksmDnl6/rL2HP5nOIS4sLAgAVWC2ym9sQ1OQhwyyqNLToWgYuIYIAzHbwJOCVJ9impQYsc%2BKXMCjMFRAEAkq%2BMlUA%2B5g2AgeZwurWsO3wmDAPgnawzbA6%2B0A8wzERr5Enk7BiMSFgGKzVj2DA/GADYNBMImSeJ6TEduCwLDcWnkcSCB7gAdgsLgTCZx0SvZiwkY5rmWdidnOb2NxuckIWfNFlmAFYJZF7mCaFurYisCnSfV8mIuw6SAHUdTdTwaqlb0oUSKEQD2LhbkTPZNciqKHcdp2uFKwCkekp3Pc9l2bcFj2vYDoyuAqwDxf9wOA%2BDm3ZfDiPvZD4NFZW6SAHkaLQZSMzo1jpj2dBUGNww3ghnM3mWS9GyOmDUoe5cRPXQwMy2mzeunGNLLzAs0BKd8ajAr867/HjllocbnhHF96KI89gwEdjDAuYHta1p0vE61AT1x71S1nbFU2efdfkPdcoc7GGe39YMhQARy8PAhUvaxrDMDR5IASSHJgOoIqhMCqY2YKpjAmIE6EMkwjzHoRFgyl94ZizMbTulEGgAGtCyrGiJZL8wpiAwmiGhRuDR0DBgiFCPYH92rPAYKgAMMFljAAQCqaSX5CCESobpBA4UwJvzbBeahsF1JMESNiOMH4BDBnugfCBBVAqYKmolcSChwqCi8H2a23NAyiUuocUqQttEImUX2HRLMNEXTENog4HM9F3AMQGCq6jzp7C0SrCxjorH3GkooY8KUsBULTKlXMLVt4xRSKkCIDFB5rkUQiXeBg/HEnEv9Z4q0KRXkwOcb8v41xfCUAGQ4jo0LoA%2BgoZqXwRzolWj5e4QIyoFKKSUspRwKl7CsNU/C70QDFLYKUwEbgmmi0ZCrJkIJpLrUAhnUe0ii5oWIColsYgxKfBvAmUQbZuqHxmc5DMVBiD5n8VDY00prG/FmW6PAqh0zZPQjmbmCIorDA/NOQ%2BRFEjqXaakAAXt8AMLAmCqC%2BPQIw1dDJ5MthoYmgy7h3IIIUkAdImAMmOPNHyPy/kAuANXawlsrh51TEwL4Lx8k3Msc46stxrKWnheAwQh5gwMGUidVM/jXBDOtkZEw0srAcqofgBQohiDoHZa46W%2BTnkwmQCwp5qgXmnPOegS5Z0jAQEPrUjpVzgBmgtJaDRZsCDzAsarVljs8ClggMEHV5YPmYEBi8bAewUX/MYOihAdVIWBxgjsrV7SW5xi%2BNEHZxAICIxoLK%2BVxsUUV3nOK94hElR/ywOgMAYBEbKwNbcp27T2RsQUB9NAiQ3imoYDqny6BcVfHLCW%2BogMU1puBZY4ZhqZyYHovvCU0Kil4E%2BT8PYoQKSexvnfIUCgIChAhCC%2B1aKYIuobeyzlFhuVBj5QK4VgqXwMGGM89SwaLkHKVWIni81KrmAJmaqEdUOU9uFVOz2Fst1yp3fcxwyAviiGGK2mFByNVWiuAWnV8w9VEtcfWqKM6Z3zt5YQwVK7JXSreWqz9nrTTWuVTc11jtmwrDbLBhV6rzRWggBWvF5Yoi9QYFWtxwG63M1cRC9xK8AioFbjODe8YOioONQs8eQUMn1zmo5RadrUzxnCjE/etJhJD2yYE5JjI7hPMuuBVAngOOlKCs%2B%2BaXwfkEHjLutd%2B6GiXn/SzGtgYTVvPqT0ppVTsBXqduh1sl4CUgo8l5DYNGooPmeOxiAZmukNN6VzIENm0MtQww5vJTm/IeXI0ZDzexqwAAkJ5dUKjvcS8tUMOzs22ac4XYj5JClFmjuj60ibTOiW9oacxCB8klRJ5Z6t7GUCkvdmB5MREUydJqLAFClKFM%2BkgQoHDWpQw26sb9SwToTF%2BA5r1zx3g9MWUsET/w23wFQX%2BQpRJ2T2MgqhWqJWNl8dItAxBBsEHClFLzQgLWIaBpa61iaQWWpLPV8sEBlB/qbCF%2BzVAxBKDccZkGD06JsHwPvfKwRTSoGQceAwJQS3Rn1sERUknb6MDWExnqgThxBQYilJKZC9j6Tyyqy1PxXuA4dBxBMU1suNm6vwUeXiGMtX4Yj6u1sUoseQGxpb1lHpxRai9JKwZNODi2g5BaCULtGSywcDlkGjRto6R2r5r2yHfvacjoiqO16nB3EcN%2BFPAv6uM1FOXEAvqNzUw0DTgmEDoia0CCA12FC3ZnW/QVerG57Fe9WjLQtvPK5%2BTD76QUddKDR/riUquXv1fe8ra4RmOb%2B6oyy6sp8MqfkjA4aJTa95xKOBVmbQgKQ2MvNxfMvXgDBhG1FUrho3DLYIJJ87DWnfcnN5gW%2B98JIQC6z17c/XTv%2BnRNVxrxvsBkYy1DvAGZUCfD%2BEQAN8x3vq4H/%2BgPRmMtGSgO0jOuSjjog43P/vT0FBA0ScNo/RwDhmDMDbRGo7b8D/LPJ9Ex/EbsrcAwZNPl1ep4UaAZp5FZ3AN7lZnLbpqoxovLNa6YbrnhQgbwL7RCpgkBf734ozWrGTYrICV4sDV49IbrYp16y7fZtjqK6JFbEqpp3AOI/LBDDbb4Nr77LCH79J2L35UxuD6TSw/5f5uZspcE0z0yMzcxsx8zNLcy8zCxSwWCCwp7RaGSsGkIf636UzUy0w8Hf6/735KF35mBUw0x0yYEMzMysxyxWAswyH8zyFyxyHiySFyGyxOEKxKz6GU57DrSciUQbxHbdyJB0B4wZbVgYFmBYHmESHCxWE8z2HcwKGOiAFGShH35uAWCIjhFmHiGWHSFxECzuGCGGQpGWAZERHZGSExE2Hyz5GKGFFxbLxRTFHcGiGVF5F2G1EGqNEOgaGiymGAwA6UYcCLC0CcDSy8B%2BAcBaCkC/QcC9FWCWCFgrAY6bA8CkAECaBDGLDIIgBmBcDlgvxMxMxcAaCSAEySAvxSBIj6CcCSDjEbHTGcC8DZoaBrEbGLBwCwAwCIAoD5iBH0BkAUC7pzhBExA7CGDABcAvwvE0C0CtSUARD3FvjMDEBvCcCrFIkNBvApw57rHcC8DdxDxpwWT3FYAkLABN7WTZp4mkBYA/JGDiCTG8D4BnZ9Scj3FEQdBQjrBTHnRVD3EwgRB/AokeBYD3HoQsBolDF8AGA14ABqmqKcnwExqx/AggIgYg7AUgMgggniag9xugCQWkKAT8lg%2BgeAEQ2akAiwC%2BNQVJxkCoeSpglgz8GgJkOsICbpfq%2BExkKcsQvAqAHUp2c%2BbJVplQ1Q6QLgQUYwrQpAgQ0wxQpQOQKQaQAg0ZSZeQ6QfQCZcwYZ/oXQkwaZbQVQeZAg3QjQWZAwZQtgBZngLQQwkwFZswZQiweYSxmpwxoxdxjJDxHAewqgAAHATMZGcZeFpJbGYOWK/K6RALgHtOpCsfMLwLiVoH%2BqQNsdLC8SMRwLcaQBKRuaQBMVMTMU8SAC8cuVKR8d8WwUWoCQESCaEM1JwAOUOSOcAMBJbLEPsbwOmHOXPnoKqcIKIOIFqQBbqeoN2QaaQJaH8IkJKR2RwGMQefcTMSnKbKQl%2BM%2BcOZIKOeCeOZOZOZVB4MCf8XfvEIua8YyaubBJOIMIDNcdubwHuS8Yef6Y8bYKeRRSuVsTsf2eWP2QAJzSzHEEyHH9kaBmCSCxAiX0V%2BlIXdnHmcUXlfGXkQBIB3n/HkCUDqWDAQkaAJAwlwlVSInvgomSmkAYkonYnZRmUElrhEmondmkm6QUm0BUmrG0ngkMlTHMl5kdRUlTEcl4Fpj3G8lblTEClClvAinclLlnQSl4mLBUAykKDylWiKmMBmUAXqnAXSCgVKB6kQU7H6DgnGnOmmkCmWl0U2npB2kOl5ZOnzE8yunGTun84tVenqQ%2BmyUBl%2BrBmVUtnFkwyRnuC1njCxlBSNmJkJC5ApkZCjUxkzU1CTU5ntAwxllNDzVDCDU1DrXLVVn3KjCbUTA9B7USAtnLDoJnX0WIUsU9l9mDlYU9TvnHHlhcCVSznL6kULBLlvHcWxCfn/WA1A3A30U7lMVyVHlsXPGKXvHKVIDXlQiaVAl/HRAPlsBPkPWvnvm8WIU/nL5/n6WyDZWam5WyBgX6lFXQWCJwXXVdmQ0cCoUEA6pBKYVY3TgvVvUQBEUo3zlIhmDkXnlUXCjDSUDwVg0gD7m3UKXQ2C3cVmAEzljnHlD8UaACVMwvz8UCWxAyV02sUcA/WUWkAqVw0/HEXRBI3aUxCmjIBCJmhcD8X/L7zDBfCqBnF8B0CGUIndkWUOXokmVYk4k2X5iEnmQOXeWYBkkuVuVMlNqeUxU0m96dB%2BXsnnJBXrCrGhX8nmmRXRVilxU01JWsQpUKlKmZVE1AUk3anyD5XgVTG6Da1GkNXWBmkWnwDWnnA1WcC2jvRN2WAvx7D%2BmBlnRYD9W5lDUQCuCFnjXoCnXTXJk1BT2LWZnxmVlbXhmlk1lZAxmrU7UNkr1Nn1k9BT0HVTBFCr0LBLBtlXVbk3XIWcB9kjndbW2OL23lixKcgBgzn4CfULkG1cVrk7HSyg2MUS3MV3363sVnlvFG0m0I0EAW2/H3mPkcCu3YVP3Timiv2xABXf3aiFKE1qkV0SCk06k10U3a1U2wUJW00Q162M3M0YWP1u4YOv3v3DCEWIMkWbCxAC2/WkDUUi10Vbni2S3gMnlQOUVy2fmSBMzSxMz8VcCDkaDSxnGxBANbmyVS1sWy30VmC609l/2bGkCBmpDOCSBAA%3D%3D

.. code-block:: cpp

    #include <concepts>
    #include <type_traits>
    #include <utility>
    #include <tuple>
    #include <typeinfo>
    #include <array>
    #include <ranges>
    #include <iostream>
    #include <string>
    #include <stdexcept>
    #include <algorithm>
    #include <string_view>

    // In a other applications these could be any other types.
    struct A { int val; };
    struct B { int val; };
    struct C { int val; };

    // Used to denote the set of possible arguments.
    template <typename T>
    concept argument_set = std::same_as<T, A> or std::same_as<T, B> or std::same_as<T, C>;


    // This could be any structural type which can be constructed from the DSL string
    struct fixed_string {
        static constexpr std::size_t max_length   = 100;
        std::array<char, max_length + 1> data_ = {}; // Allways contains null at the end

        [[nodiscard]] explicit constexpr fixed_string(const std::string_view input) {
            if (input.size() > max_length)
                throw std::logic_error("fixed_string max capacity exceeded!");

            std::ranges::copy(input, data_.data());
        }

        template<std::size_t N>
            requires(N <= max_length)
        [[nodiscard]] constexpr fixed_string(const char (&input)[N])
            : fixed_string(static_cast<std::string_view>(input)) {}

        [[nodiscard]] constexpr std::string_view sv() const {
            return std::string_view(data_.begin());
        }
    };

    // Logic to check if type and argument character match.
    template <argument_set T>
    consteval bool type_and_char_match(const char c) {
        if (std::same_as<T, A>)
            return c == 'A';
        else if (std::same_as<T, B>)
            return c == 'B';
        else // Has to be of type C
            return c == 'C';
    }

    template<fixed_string S, typename... P>
    consteval bool params_are_correct() {
        // If length of string and amount of arguments is different we know it can not be correct.
        if (S.sv().size() != sizeof...(P)) return false;

        // Use immediately invoked lambda with index_sequence to get handle to type I := std::size_t...
        // which then can be folded together with A to check if all parameters types match the character.
        return []<std::size_t... I>(std::index_sequence<I...>) {
            return (type_and_char_match<P>(S.sv()[I]) and ...);
        }(std::make_index_sequence<sizeof...(P)>{});
    }

    // DSL function object
    template <fixed_string S>
    struct custom_args {
        template <argument_set... P>
        requires (params_are_correct<S, P...>())
        void operator()(P... params)
        {
           ((std::cout << typeid(params).name() << " is " << params.val << "\n"), ... );
        }
    };

    template<fixed_string expr>
    constexpr auto operator""_p() -> custom_args<expr> {
        return { };
    };

    int main() {
        std::cout << "ABC:\n";
        "ABC"_p(A{1}, B{2}, C{3});
        std::cout << "ABBCCC:\n";
        "ABBCCC"_p(A{1}, B{2}, B{3}, C{4}, C{5}, C{6});

        // These do not compile:
        // ""_p(A{1}, B{2}, C{3});
        // "CBA"_p(A{1}, B{2}, C{3});
        // "BA"_p(A{1}, B{2}, C{3});
        //
        // "ABC"_p(B{2}, C{3});
        // "ABC"_p();
    }
