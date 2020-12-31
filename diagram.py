from diagrams import Cluster, Diagram

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
        kdc = Docker("KDC")
    client >> kdc
    hive >> kdc
    hive >> postgres
    presto >> minio
    presto >> kdc
    client >> presto >> hive

diag