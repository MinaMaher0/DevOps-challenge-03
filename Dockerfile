FROM python:3.7

RUN apt-get update
RUN apt-get install python3-pip -y

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT python 
CMD ["hello.py"]