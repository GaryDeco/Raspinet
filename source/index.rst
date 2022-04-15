.. Raspinet documentation master file, created by
   sphinx-quickstart on Sun Feb 13 23:43:42 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to RasPiNet's documentation!
====================================
*This Page is currently under construction!!*
*More coming soon...*

.. toctree::
   :maxdepth: 2
   :caption: Contents:

.. image:: https://readthedocs.org/projects/raspinet/badge/?version=latest
   :target: https://raspinet.readthedocs.io/en/latest/?badge=latest
   :alt: Documentation Status

Pages
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

CLI Commands Quick Reference
=========================

defscan 

+----------------------------+-----------------------------------------------------------+
| **defscan** **[arg1]**                                                                 |
+----------------------------+-----------------------------------------------------------+
| **Argument**               |    **Description**                                        |
+----------------------------+-----------------------------------------------------------+
| usage:                     |  ``defscan [option1]``                                    |
+----------------------------+-----------------------------------------------------------+
|about:                      |  Default scans ultilizing Nmap for network discovery      |
|                            |  Determines and scans the entire subnet by default:       | 
|                            |  i.e., 192.168.68.25/24                                   |
+----------------------------+-----------------------------------------------------------+
|``[-i | -inv]``             |  Scan Type: [``nmap -n -sn <tgt>``] No port scan.         |
|                            |  Return a text file with the list of live host IP's       |
|                            |  Ovewrites the file and makes a date/time stamped copy    |
+----------------------------+-----------------------------------------------------------+
|``[-po | -ports_open]``     |  Scan Type: [``nmap --top-ports 100 -F --open <tgt>``]    |
|                            |  A quick scan of the top 100 ports. Returns a text file   |
|                            |  with the list of host IP's and their open ports.         |
+----------------------------+-----------------------------------------------------------+
|``[-h | -help]``            |  Call the help menu                                       |
+----------------------------+-----------------------------------------------------------+
|``[]``                      |  Reference to help menu                                   |
+----------------------------+-----------------------------------------------------------+
| **smartscan** **[arg1]**                                                               |
+----------------------------+-----------------------------------------------------------+
| **Argument**               | **Description**                                           |
+----------------------------+-----------------------------------------------------------+
| ``[-h | -help]``           |  Call the help menu                                       |            
+----------------------------+-----------------------------------------------------------+
|``[]``                      |  Reference to help menu                                   |
+----------------------------+-----------------------------------------------------------+


