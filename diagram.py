from diagrams import Cluster, Diagram, Edge

from diagrams.aws.storage import S3
from diagrams.onprem.analytics import Hive
from diagrams.onprem.client import Client
from diagrams.onprem.container import Docker
from diagrams.onprem.database import Postgresql

with Diagram(filename="diagram") as diag:
    client = Client("Client")

    with Cluster("EXAMPLE.COM"):
        hive = Hive("Hive metastore")
        postgres = Postgresql("PostgreSQL")
        minio = S3("Minio (S3)")
        presto = Docker("Presto")
        kdc = Docker("Kerberos KDC")
    client >> Edge(color="darkgreen") >> kdc
    hive >> Edge(color="darkgreen") >> kdc
    hive >> postgres
    hive >> minio
    presto >> minio
    presto >> Edge(color="darkgreen") >> kdc
    client >> Edge(color="darkgreen") >> presto >> Edge(color="darkgreen") >> hive
    client >> hive

diag