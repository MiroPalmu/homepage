:blogpost: true
:date: 2024-02-03
:tags: blog, C++, desing, principle, noexcept, constexpr, consteval
:author: Miro Palmu

Demystifying Lakos Rule via Visualization and How It Could Relate to Constexpr
==============================================================================

If you have been interested in C++ standard committee works,
you have probably come contact with Lakos rule (named after John Lakos).
It is a C++ function API design principle related to noexcept,
which is especially relevant in C++ standard library.
With `language support for contracts`_ on its way hopefully in C++26,
the Lakos rule has proven its relevance once again.
For more info on contracts and Lakos rule see papers `P2831`_ and `P2861`_ .

.. _language support for contracts: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2900r2.pdf
.. _P2831: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2831r0.pdf
.. _P2861: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2861r0.pdf

Lakos rule has been explained in numerous papers and conference talks
(see references of the above two papers or consult your favorite search engine).
However the explanations that I have come across focus on practical examples and
how Lakos rule comes into play.
This might be a preferable explanation format for many people but
in this blog post I will try to argue for Lakos rule in more abstract and visual way.
In the end, I will attempt to argue how arguments presented in this blog post for
Lakos rule, applies for constexpr as well.
As a disclaimer things on this post are how I have interpreted them as a C++ enthusiast.
They might be incorrect or partial truths. I’m always happy to hear if you think that I’m wrong.

Lakos rule
----------

In essence Lakos rule is with some caveats:

    Narrow contracts and noexcept are inherently incompatible.

To unpack this, first we need some definitions.
First let’s assume that we have a function :math:`f`,
which can take arguments from some set :math:`A`.
We can represent set :math:`A` as `Venn diagram`_:

.. _Venn diagram: https://en.wikipedia.org/wiki/Venn_diagram

.. image:: lakos_rule_visualized_assets/lakos_diagram-1.svg

Now, when we talk about having contracts on the arguments of :math:`f`,
it means that some elements in :math:`A` are not valid inputs for :math:`f`,
even if :math:`f` can technically accept them.
Passing them to :math:`f` would result in some form of undefined behavior.
Let’s call subset of :math:`A` which are valid input to :math:`f` a set :math:`B` and
color elements of :math:`B` with green and assume that every other element of :math:`A` is non-valid.

.. image:: lakos_rule_visualized_assets/lakos_diagram-2.svg

If :math:`A = B` i.e. every element of :math:`A` is valid input,
it is said that :math:`f` has wide contract.
Conversely if :math:`A \not = B`, it is said that :math:`f` has narrow contract.

.. image:: lakos_rule_visualized_assets/lakos_diagram-3.svg

Now let’s say that author of function :math:`f` belives that it will never throw
when called with elements from the valid subset :math:`B` and thus
sets :math:`f` to be noexcpet.
Calling :math:`f` with elements not in :math:`B` would lead to undefined behavior anyway.
Let’s denote all the elements of :math:`A` which would result in crash
if exception is raised in :math:`f` with hatch pattern.
This might seem silly because every call of :math:`f`
with any element in :math:`A` is a noexcept call,
and the arguments do not change the noexcept-ness of :math:`f`.
However, this is, in fact, the essence of why the Lakos rule is relevant.

.. image:: lakos_rule_visualized_assets/lakos_diagram-4.svg

Now, the author of :math:`f` writes some tests for it.
Each test takes an element from :math:`A`, calls :math:`f` with it,
and checks if the result is correct.
We can denote these tested elements of :math:`A` with crosses.

.. image:: lakos_rule_visualized_assets/lakos_diagram-5.svg

We notice that elements that are not in set :math:`B` can not be tested,
because it would lead to undefined behavior.
However, the author of :math:`f` wants to ensure that :math:`f`
is not called with elements outside of :math:`B` and inserts assertion checks
to detect elements that are not in :math:`B`.
Since assertions are new code, they should also be tested,
so they need to somehow signal the calling test when an assertion failure occurs. 

.. image:: lakos_rule_visualized_assets/lakos_diagram-6.svg

Due to the noexcept "zone" extending beyond set :math:`B`,
the signal can not be thrown as an exception.
The decision on noexcept has already been made because noexcept effects all elements in :math:`A`.
It can not be applied only to some subset of :math:`A`.

Ok, but what about removing the noexcept?
In many cases, yes, this can be done,
but we assume that in this case, it can not be taken away,
because users of :math:`f` already are relaying on noexcept nature of :math:`f`.
Remember that Lakos rule is most relevant in C++ standard library
which one of the main features is backwards compatibility.

It’s worth noting that the wide contract case does not have this problem
because there is no preconditions to assert.
Though, of course, if the author of :math:`f` wants to assert some internal invariant,
the same problem comes up.

While there are some alternatives
(such as setjmp/longjmp, child threads, "stackful coroutines" and
most importantly death testing),
none of them are as viable as exceptions,
but the "bluntness" of noexcept made this form of contract checking impossible.
For a comparison between different testing methods and why exceptions are superior,
see Pablo Halpern’s and Timur Doumler’s `excellent talk at CppCon 2023`_.

.. _excellent talk at CppCon 2023: https://www.youtube.com/watch?v=BS3Nr2I32XQ

If we go back a little,
there is another reason why noexcept is too much of a "blunt" tool
for functions with a narrow contract.
Let's say once again that the author of :math:`f` has chosen to make it noexcept.

.. image:: lakos_rule_visualized_assets/lakos_diagram-7.svg

Now, time goes by, and the author gets a nice idea on how to make :math:`f` more generic.
It can now handle a subset :math:`C` of :math:`A`,
which is a superset of :math:`B`.
For a wide contract, this is impossible because :math:`B` cannot be made any larger than :math:`A`.

.. image:: lakos_rule_visualized_assets/lakos_diagram-8.svg

Once again, because the choice of noexcept has already been made,
all new possible arguments in :math:`C` are automatically noexcept.
This limits the design and possible functionality that :math:`f` can achieve
with the new elements from :math:`C`.
This argument can even be made without the new set :math:`C`.
The author of :math:`f` cannot make any enhancements to implementation of :math:`f`
that would involve exceptions.

Summary
-------

Now getting back to Lakos rule, narrow contracts and noexcept are inherently incompatible,
because narrow contract means that there is some arguments (in :math:`A` but not in :math:`B`)
for which the functionality has not been decided,
but noexcept limits functionality of all possible arguments.
Noexcept can **not** be applied only to subset of :math:`A`.
In case of wide contracts the functionality of :math:`f`
has been decided for all possible arguments (:math:`A = B`),
so there is no new arguments which design space would be limited with noexcept.

Caveats
-------

The caveats to Lakos rule arise in the form of special cases.
To get a crasp on the nature of these cases, here is a list of requirements
that such case needs to fulfill, proposed by John Lakos himself in `P2861`_:

- The operation the function provides has an inherently narrow contract.
- A primary use case would be lost if it had a throwing specification.
- To disallow throwing in response to a contract violation is acceptable.
- No better design alternative is available (or foreseeable).

I will not go in any more depth in this matter and leave more thorough explanataion
to `P2861`_. It is a paper which gives an excellent
and comprehensive explanation of the Lakos rule.

Constexpr
---------

I will end this blog post attempting to argue why arguments of Lakos rule
have implications for constexpr as well.
Lets call the set of possible "call times" a set :math:`T`,
which contains only two elements: run time and compile time (constant-evaluation).
Then lets define set of possible "call times" for function :math:`f` a set :math:`T_f`.

For function :math:`f` without constexpr or consteval specifier
:math:`T_f = \{\text{run time}\}`. In some cases function :math:`f` with constexpr specifier
can not ever be executed during compile time, because it uses some non-constant-evaluatable
functionality, and for these :math:`T_f = \{\text{run time}\}` as well.
I will not be exact what non-constant-evaluatable functionality is
because it is changing from one version of the standard to next.

For functions :math:`f` with constexpr specifier and
which only uses constant-evaluatable functionality,
:math:`T_f = \{\text{run time}, \text{compile time}\}`.
Lastly for function :math:`f` which has consteval specifier,
:math:`T_f = \{\text{compile time}\}`. [#]_

The argument presented in this blog post for Lakos rule was that
noexcept should not be applied to functions with narrow contracts
because it limits the potential functionality for all arguments,
even for those for which the functionality has yet not been decided.
Now, with a similar argument,
one can argue that constexpr should be applied to every function
and only constant-evaluatable functionality should be used in them,
for these functions :math:`T_f = T`.
This is the only way that does not impose any restrictions on
potential functionality of the function.

I believe this is a valid argument, albeit weaker than Lakos rule.
The significance of Lakos rule lies in the difficulty of removing noexcept once applied.
However, for functions with :math:`T_f \not = T`, it is relatively easy to add constexpr
or change consteval to constexpr.
What is not easy to change is use of non-constant-evaluatable functionality
which prevent constexpr functions to be executed during compile time.
Additionally, there is also complications involving SFINAE,
as it can be used to choose overload based on whether a function is constant-evaluatable,
potentially altering the meaning of other code when adding constexpr.
See `this answer on Stack Overflow`_ for an exapmle.
Even the `C++ standard`_ prohibits implementers of standard library from adding constexpr
where it is not explicitly required by the standard.
See `N3788`_ for more detail.

.. _this answer on Stack Overflow: https://stackoverflow.com/a/32398825
.. _C++ standard: https://eel.is/c++draft/constexpr.functions
.. _N3788: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2013/n3788.html#2013


Of course, similar to Lakos rule, there are exceptions for constexpr.
If the functionality of a function inherently belongs to constant-evaluation
(e.g., reflection functions proposed in `P2996`_),
it is more self-documenting code to specify those functions as consteval.
Conversely, if the functionality of a function inherently belongs to runtime
or is impossible to implement with only constant-evaluatable functions
(e.g., I/O functions), it should not have a constexpr specifier.
Also all constant-evaluatable functions have to be in a header.
Increased compilation times can be a significant drawback and deal-breaker for many,
but let's hope that C++ modules will bring salvation.

.. _P2996: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2996r0.html

This brings the end of this blog post.
Thank you for reading this far! Feedback is always appreciated.

.. [#] For functions which are ill-formed, :math:`T_f = \emptyset` (empty set).
