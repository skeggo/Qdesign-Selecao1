
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import * as bodyParser from 'body-parser';
import { Server as IOServer } from 'socket.io';
import { setSocketServer } from './socket-emitter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const rawOrigins = process.env.CORS_ORIGINS ?? 'http://localhost:3000,http://localhost:3002';
  const allowedOrigins = rawOrigins.split(',').map((o) => o.trim());

  // Enable CORS for the frontend
  app.enableCors({
    origin: allowedOrigins,
    credentials: true,
  });
  
  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  app.use(bodyParser.json({ limit: '50mb' }));
  app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
  
  
  // Global prefix for API
  app.setGlobalPrefix('api');
  

  const port = process.env.PORT ?? 3001;
  const server = await app.listen(port);

  // Attach socket.io to the same HTTP server
  const io = new IOServer(server.getHttpServer ? server.getHttpServer() : server, {
    cors: {
      origin: allowedOrigins,
      credentials: true,
    },
  });
  setSocketServer(io);

  console.log(`Server running on http://localhost:${port}`);
}
bootstrap();
