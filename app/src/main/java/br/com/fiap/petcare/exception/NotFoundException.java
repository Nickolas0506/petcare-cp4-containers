package br.com.fiap.petcare.exception;

/** Lancada quando o recurso pedido nao existe no banco (vira HTTP 404). */
public class NotFoundException extends RuntimeException {
    public NotFoundException(String mensagem) {
        super(mensagem);
    }
}
