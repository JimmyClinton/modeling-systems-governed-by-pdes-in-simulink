# Model Order Reduction

This directory demonstrates the application of a model order reduction technique known as modal
truncation to the high fidelity finite element model of the CPU and heat sink. This method works
by projecting the model equations onto a subspace of the modal decomposition of the original 
problem. A projection matrix is constructed by retaining a user-specified number of eigenvectors
to form a basis that spans the reduced modal space. This example has symmetric stiffness and mass
matrices from the finite element formulation so solving the generalized eigenvalue problem will
result in a single projection matrix, V, meaning this will perform a Galerkin projection. The
subspace in this example is chosen to be the "k" lowest-frequency modes. In the application of
this MOR technique, the high frequency modes are often discarded due to limitations of actuators
and sensors in physical systems. [1][2][3]

The transformation of the DSS system is done as follows:

Ar = V'*A*V;
Br = V'*B  ;
Cr =    C*V;
Dr =    D  ;
Er = V'*E*V;

This technique shows considerable speedup while maintaining acceptable error deviation for this
model. Modal truncation is a straightforward model order reduciton technique but not always possible
to implement due to difficulty in assesing the dominant modes of a system. [4] It was a good fit for
this problem and can be extended to other systems where the DSS matrices are symmetric (to use
Galerkin projection) and are of full rank. This method requires upfront computational cost to find
an acceptable reduced order model of the finite element system but it has benefits of reducing
simulation complexity, preserving stability, and leaving feedthrough unaffected. [5]

# References and Further Reading
1. https://w3.onera.fr/more/sites/w3.onera.fr.more/files/2016%20-%20lecture%2002%20-%20Overview%20of%20the%20model%20approximation%20methods.pdf
2. https://web.stanford.edu/group/frg/course_work/CME345/CA-CME345-Ch3.pdf
3. https://onlinelibrary.wiley.com/doi/pdf/10.1002/pamm.201210343
4. https://www.scorec.rpi.edu/REPORTS/2005-21.pdf
5. https://perso.uclouvain.be/paul.vandooren/ThesisGrimme.pdf


Contents:

test_script.m: script to compare different model order reduction parameters, visualize to let user make choice

test_model.slx: simple DSS block driven by random input to compare MOR parameters to baseline FE formulation